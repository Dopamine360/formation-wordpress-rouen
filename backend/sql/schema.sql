-- PostgreSQL schema for referendum system
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS referendums (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  start_at TIMESTAMP WITH TIME ZONE NOT NULL,
  end_at TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS choices (
  id SERIAL PRIMARY KEY,
  referendum_id INTEGER NOT NULL REFERENCES referendums(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_choices_referendum ON choices(referendum_id);

CREATE TABLE IF NOT EXISTS votes (
  id SERIAL PRIMARY KEY,
  referendum_id INTEGER NOT NULL REFERENCES referendums(id) ON DELETE CASCADE,
  choice_id INTEGER NOT NULL REFERENCES choices(id) ON DELETE CASCADE,
  vote_token UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_votes_ref ON votes(referendum_id);
CREATE INDEX IF NOT EXISTS idx_votes_choice ON votes(choice_id);

CREATE TABLE IF NOT EXISTS user_votes (
  id SERIAL PRIMARY KEY,
  wp_user_id INTEGER NOT NULL,
  referendum_id INTEGER NOT NULL REFERENCES referendums(id) ON DELETE CASCADE,
  link_token UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(wp_user_id, referendum_id)
);
CREATE INDEX IF NOT EXISTS idx_user_votes_ref ON user_votes(referendum_id);

-- View to see aggregated results per choice
CREATE OR REPLACE VIEW referendum_results AS
SELECT c.referendum_id, c.id AS choice_id, c.label, COUNT(v.id) AS total
FROM choices c
LEFT JOIN votes v ON v.choice_id = c.id
GROUP BY c.referendum_id, c.id, c.label
ORDER BY c.referendum_id, c.sort_order;
