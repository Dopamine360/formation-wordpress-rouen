import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import referendumRoutes from './routes/referendums.js';
import voteRoutes from './routes/votes.js';

dotenv.config();

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.use('/', referendumRoutes);
app.use('/', voteRoutes);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Referendum service running on port ${PORT}`);
});
