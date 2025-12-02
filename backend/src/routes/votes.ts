import { Router } from 'express';
import { pool, withTransaction } from '../db/pool.js';
import { requireUserJWT, AuthenticatedRequest } from '../middleware/auth.js';
import { z } from 'zod';

const router = Router();

const voteSchema = z.object({
  referendum_id: z.number(),
  choice_id: z.number(),
  wp_user_id: z.number()
});

router.post('/votes', requireUserJWT, async (req: AuthenticatedRequest, res) => {
  const parsed = voteSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.format() });
  const { referendum_id, choice_id, wp_user_id } = parsed.data;
  if (req.user!.id !== wp_user_id) return res.status(403).json({ error: 'Token user mismatch' });

  const now = new Date();
  const ref = await pool.query(
    'SELECT * FROM referendums WHERE id = $1 AND status = $2 AND start_at <= $3 AND end_at >= $3',
    [referendum_id, 'open', now]
  );
  if (ref.rowCount === 0) return res.status(400).json({ error: 'Referendum not open' });

  try {
    const result = await withTransaction(async (client) => {
      const existing = await client.query('SELECT id, link_token FROM user_votes WHERE wp_user_id = $1 AND referendum_id = $2', [wp_user_id, referendum_id]);
      if (existing.rowCount > 0) {
        return { status: 'already', link_token: existing.rows[0].link_token };
      }
      const voteInsert = await client.query(
        'INSERT INTO votes (referendum_id, choice_id) VALUES ($1,$2) RETURNING vote_token',
        [referendum_id, choice_id]
      );
      const linkToken = voteInsert.rows[0].vote_token;
      await client.query(
        'INSERT INTO user_votes (wp_user_id, referendum_id, link_token) VALUES ($1,$2,$3)',
        [wp_user_id, referendum_id, linkToken]
      );
      return { status: 'created', link_token: linkToken };
    });
    res.status(result.status === 'already' ? 200 : 201).json(result);
  } catch (err: any) {
    if (err.code === '23505') return res.status(409).json({ error: 'Already voted' });
    res.status(500).json({ error: 'Failed to vote' });
  }
});

router.get('/results/:referendum_id', requireUserJWT, async (req, res) => {
  const { referendum_id } = req.params;
  const rows = await pool.query(
    `SELECT c.id as choice_id, c.label, COUNT(v.id) as total
     FROM choices c LEFT JOIN votes v ON v.choice_id = c.id
     WHERE c.referendum_id = $1
     GROUP BY c.id, c.label
     ORDER BY c.sort_order ASC`,
    [referendum_id]
  );
  res.json(rows.rows);
});

router.get('/me/votes', requireUserJWT, async (req: AuthenticatedRequest, res) => {
  const userId = req.user!.id;
  const rows = await pool.query(
    `SELECT uv.referendum_id, uv.link_token, c.id as choice_id, c.label
     FROM user_votes uv
     JOIN votes v ON v.vote_token = uv.link_token
     JOIN choices c ON c.id = v.choice_id
     WHERE uv.wp_user_id = $1`,
    [userId]
  );
  res.json(rows.rows);
});

export default router;
