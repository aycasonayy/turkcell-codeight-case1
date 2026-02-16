-- Seed
create table users (
  user_id text primary key,
  name text not null,
  city text,
  segment text
);

create table games (
  game_id text primary key,
  game_name text not null,
  genre text
);

create table activity_events (
  event_id text primary key,
  user_id text not null references users(user_id),
  game_id text not null references games(game_id),
  date date not null,
  login_count int not null,
  play_minutes int not null,
  pvp_wins int not null,
  coop_minutes int not null,
  topup_try int not null
);
create index ix_events_user_date on activity_events(user_id, date);

create table quests (
  quest_id text primary key,
  quest_name text not null,
  quest_type text not null,
  condition text not null,
  reward_points int not null,
  priority int not null,
  is_active boolean not null
);

create table badges (
  badge_id text primary key,
  badge_name text not null,
  condition text not null,
  level int not null
);

-- Output
create table quest_awards (
  award_id text primary key,
  user_id text not null references users(user_id),
  as_of_date date not null,
  triggered_quests text not null,
  selected_quest text not null,
  reward_points int not null,
  suppressed_quests text,
  "timestamp" timestamptz not null
);

create table points_ledger (
  ledger_id text primary key,
  user_id text not null references users(user_id),
  points_delta int not null,
  source text not null,
  source_ref text,
  created_at timestamptz not null
);
create index ix_ledger_user_time on points_ledger(user_id, created_at);

create table badge_awards (
  user_id text not null references users(user_id),
  badge_id text not null references badges(badge_id),
  awarded_at timestamptz not null,
  primary key(user_id, badge_id)
);

create table notifications (
  notification_id text primary key,
  user_id text not null references users(user_id),
  channel text not null,
  message text not null,
  sent_at timestamptz not null
);
