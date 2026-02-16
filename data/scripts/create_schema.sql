-- 0) İsteğe bağlı: her şeyi tek schema altında toplayalım
CREATE SCHEMA IF NOT EXISTS app;
SET search_path TO app;

-- 1) USERS (seed)
CREATE TABLE users (
  user_id   TEXT PRIMARY KEY,
  name      TEXT NOT NULL,
  city      TEXT,
  segment   TEXT
);

-- 2) GAMES (seed)
CREATE TABLE games (
  game_id    TEXT PRIMARY KEY,
  game_name  TEXT NOT NULL,
  genre      TEXT
);

-- 3) ACTIVITY EVENTS (seed)  --> senin asıl ham verin
CREATE TABLE activity_events (
  event_id      TEXT PRIMARY KEY,
  user_id       TEXT NOT NULL REFERENCES users(user_id),
  date          DATE NOT NULL,
  game_id       TEXT NOT NULL REFERENCES games(game_id),
  login_count   INT  NOT NULL CHECK (login_count >= 0),
  play_minutes  INT  NOT NULL CHECK (play_minutes >= 0),
  pvp_wins      INT  NOT NULL CHECK (pvp_wins >= 0),
  coop_minutes  INT  NOT NULL CHECK (coop_minutes >= 0),
  topup_try     INT  NOT NULL CHECK (topup_try >= 0)
);
CREATE INDEX IF NOT EXISTS ix_events_user_date ON activity_events(user_id, date);

-- 4) QUESTS (seed)
CREATE TABLE quests (
  quest_id       TEXT PRIMARY KEY,
  quest_name     TEXT NOT NULL,
  quest_type     TEXT NOT NULL,      -- DAILY / WEEKLY / STREAK (text bırakıyoruz)
  condition      TEXT NOT NULL,      -- ör: login_count_today >= 1
  reward_points  INT  NOT NULL CHECK (reward_points >= 0),
  priority       INT  NOT NULL CHECK (priority >= 0),
  is_active      BOOLEAN NOT NULL
);

-- 5) BADGES (seed)
CREATE TABLE badges (
  badge_id    TEXT PRIMARY KEY,
  badge_name  TEXT NOT NULL,
  condition   TEXT NOT NULL,         -- ör: total_points >= 300
  level       INT  NOT NULL CHECK (level >= 0)
);

-- 6) QUEST AWARDS (output)
-- Bir kullanıcı için bir "as_of_date" gününde karar/ödül kaydı.
CREATE TABLE quest_awards (
  award_id          TEXT PRIMARY KEY,
  user_id           TEXT NOT NULL REFERENCES users(user_id),
  as_of_date        DATE NOT NULL,
  selected_quest    TEXT NOT NULL REFERENCES quests(quest_id),
  reward_points     INT  NOT NULL CHECK (reward_points >= 0),
  created_at        TIMESTAMPTZ NOT NULL
);

-- 6b) QUEST AWARD ITEMS (normalize!)
-- triggered/suppressed/selected gibi listeleri burada tutuyoruz.
CREATE TABLE quest_award_items (
  award_id   TEXT NOT NULL REFERENCES quest_awards(award_id) ON DELETE CASCADE,
  quest_id   TEXT NOT NULL REFERENCES quests(quest_id),
  status     TEXT NOT NULL CHECK (status IN ('TRIGGERED','SELECTED','SUPPRESSED')),
  PRIMARY KEY (award_id, quest_id)
);
CREATE INDEX IF NOT EXISTS ix_award_items_award ON quest_award_items(award_id);

-- 7) QUEST DECISIONS (output) - açıklanabilirlik/log
CREATE TABLE quest_decisions (
  decision_id             TEXT PRIMARY KEY,
  user_id                  TEXT NOT NULL REFERENCES users(user_id),
  as_of_date               DATE NOT NULL,
  selected_reward_points   INT  NOT NULL,
  reason                   TEXT NOT NULL,
  created_at               TIMESTAMPTZ NOT NULL
);

-- 8) POINTS LEDGER (output) - puan defteri
CREATE TABLE points_ledger (
  ledger_id    TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(user_id),
  points_delta INT  NOT NULL,
  source       TEXT NOT NULL,       -- ör: QUEST_REWARD
  source_ref   TEXT,                -- ör: QA-100
  created_at   TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_ledger_user_time ON points_ledger(user_id, created_at);

-- 9) BADGE AWARDS (output) - kullanıcıya badge verildi kaydı
CREATE TABLE badge_awards (
  user_id     TEXT NOT NULL REFERENCES users(user_id),
  badge_id    TEXT NOT NULL REFERENCES badges(badge_id),
  awarded_at  TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, badge_id)
);

-- 10) NOTIFICATIONS (output)
CREATE TABLE notifications (
  notification_id  TEXT PRIMARY KEY,
  user_id          TEXT NOT NULL REFERENCES users(user_id),
  channel          TEXT NOT NULL,
  message          TEXT NOT NULL,
  sent_at          TIMESTAMPTZ NOT NULL
);

-- 11) DERIVED VIEW: total_points (ledger’dan)
CREATE OR REPLACE VIEW v_user_total_points AS
SELECT
  u.user_id,
  u.name,
  u.city,
  u.segment,
  COALESCE(SUM(l.points_delta), 0) AS total_points
FROM users u
LEFT JOIN points_ledger l ON l.user_id = u.user_id
GROUP BY u.user_id, u.name, u.city, u.segment;

-- 12) DERIVED VIEW: leaderboard (rank kuralı)
CREATE OR REPLACE VIEW v_leaderboard AS
SELECT
  DENSE_RANK() OVER (ORDER BY total_points DESC, user_id ASC) AS rank,
  user_id,
  total_points
FROM (
  SELECT user_id, COALESCE(SUM(points_delta),0) AS total_points
  FROM points_ledger
  GROUP BY user_id
) t
ORDER BY rank, user_id;
