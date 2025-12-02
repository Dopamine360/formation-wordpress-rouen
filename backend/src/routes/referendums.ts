import { Router } from 'express';
import { pool } from '../db/pool.js';
import { requireAdminKey } from '../middleware/auth.js';
import { z } from 'zod';

const router = Router();

const referendumSchema = z.object({
  title: z.string().min(3),
  description: z.string().min(3),
  start_at: z.string(),
  end_at: z.string(),
  status: z.string().optional().default('open'),
  choices: z.array(z.object({ label: z.string().min(1), sort_order: z.number().optional() }))
});

router.post('/admin/referendums', requireAdminKey, async (req, res) => {
  const parsed = referendumSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.format() });
  const { title, description, start_at, end_at, status, choices } = parsed.data;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const refResult = await client.query(
      'INSERT INTO referendums (title, description, start_at, end_at, status) VALUES ($1,$2,$3,$4,$5) RETURNING id',
      [title, description, start_at, end_at, status]
    );
    const referendumId = refResult.rows[0].id;
    for (const [index, choice] of choices.entries()) {
      await client.query(
        'INSERT INTO choices (referendum_id, label, sort_order) VALUES ($1,$2,$3)',
        [referendumId, choice.label, choice.sort_order ?? index]
      );
    }
    await client.query('COMMIT');
    res.status(201).json({ id: referendumId });
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Failed to create referendum' });
  } finally {
    client.release();
  }
});

router.get('/referendums', async (_req, res) => {
  const now = new Date();
  const result = await pool.query(
    'SELECT * FROM referendums WHERE status = $1 AND start_at <= $2 AND end_at >= $2 ORDER BY start_at ASC',
    ['open', now]
  );
  const refs = result.rows;
  const choicesResult = await pool.query('SELECT * FROM choices WHERE referendum_id = ANY($1)', [refs.map((r) => r.id)]);
  const grouped = choicesResult.rows.reduce((acc: any, row) => {
    acc[row.referendum_id] = acc[row.referendum_id] || [];
    acc[row.referendum_id].push(row);
    return acc;
  }, {} as Record<number, any[]>);
  res.json(refs.map((r) => ({ ...r, choices: grouped[r.id] || [] })));
});

router.get('/referendums/:id', async (req, res) => {
  const { id } = req.params;
  const ref = await pool.query('SELECT * FROM referendums WHERE id = $1', [id]);
  if (ref.rowCount === 0) return res.status(404).json({ error: 'Not found' });
  const choices = await pool.query('SELECT * FROM choices WHERE referendum_id = $1 ORDER BY sort_order ASC', [id]);
  res.json({ ...ref.rows[0], choices: choices.rows });
});

export default router;
