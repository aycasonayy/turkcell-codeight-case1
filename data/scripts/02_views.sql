-- Generated split from karısıkquery.sql
-- 02_views.sql

CREATE OR REPLACE VIEW app.v_as_of_date AS
SELECT MAX(date) AS as_of_date
FROM app.activity_events;

CREATE OR REPLACE VIEW app.v_as_of_date AS
SELECT MAX(date) AS as_of_date
FROM app.activity_events;

CREATE OR REPLACE VIEW app.v_as_of_date AS
SELECT MAX(date) AS as_of_date
FROM app.activity_events;

CREATE OR REPLACE VIEW app.v_user_state AS
WITH params AS (
  SELECT as_of_date FROM app.v_as_of_date
),

today AS (
  SELECT
    e.user_id,
    SUM(e.login_count)   AS login_count_today,
    SUM(e.play_minutes)  AS play_minutes_today,
    SUM(e.pvp_wins)      AS pvp_wins_today,
    SUM(e.coop_minutes)  AS coop_minutes_today,
    SUM(e.topup_try)     AS topup_try_today
  FROM app.activity_events e, params p
  WHERE e.date = p.as_of_date
  GROUP BY e.user_id
),

last7 AS (
  SELECT
    e.user_id,
    SUM(e.play_minutes)  AS play_minutes_7d,
    SUM(e.topup_try)     AS topup_try_7d,
    SUM(e.login_count)   AS logins_7d
  FROM app.activity_events e, params p
  WHERE e.date BETWEEN (p.as_of_date - 6) AND p.as_of_date
  GROUP BY e.user_id
),

user_days AS (
  SELECT
    u.user_id,
    gs::date AS d
  FROM app.users u, params p
  CROSS JOIN generate_series(
    (p.as_of_date::timestamp - interval '60 days'),
    (p.as_of_date::timestamp),
    interval '1 day'
  ) gs
),

daily_login AS (
  SELECT
    ud.user_id,
    ud.d,
    COALESCE(SUM(e.login_count),0) AS login_count_day
  FROM user_days ud
  LEFT JOIN app.activity_events e
    ON e.user_id = ud.user_id
   AND e.date    = ud.d
  GROUP BY ud.user_id, ud.d
),

streak_marked AS (
  SELECT
    dl.user_id,
    dl.d,
    dl.login_count_day,
    SUM(CASE WHEN dl.login_count_day = 0 THEN 1 ELSE 0 END)
      OVER (PARTITION BY dl.user_id ORDER BY dl.d DESC) AS zero_seen
  FROM daily_login dl
),

streak_calc AS (
  SELECT
    user_id,
    COUNT(*) AS login_streak_days
  FROM streak_marked
  WHERE zero_seen = 0 AND login_count_day > 0
  GROUP BY user_id
)

SELECT
  u.user_id,
  u.name,
  u.city,
  u.segment,
  COALESCE(t.login_count_today,0)  AS login_count_today,
  COALESCE(t.play_minutes_today,0) AS play_minutes_today,
  COALESCE(t.pvp_wins_today,0)     AS pvp_wins_today,
  COALESCE(t.coop_minutes_today,0) AS coop_minutes_today,
  COALESCE(t.topup_try_today,0)    AS topup_try_today,
  COALESCE(l7.play_minutes_7d,0)   AS play_minutes_7d,
  COALESCE(l7.topup_try_7d,0)      AS topup_try_7d,
  COALESCE(l7.logins_7d,0)         AS logins_7d,
  COALESCE(sc.login_streak_days,0) AS login_streak_days,
  COALESCE(tp.total_points,0)      AS total_points
FROM app.users u
LEFT JOIN today t ON t.user_id = u.user_id
LEFT JOIN last7 l7 ON l7.user_id = u.user_id
LEFT JOIN streak_calc sc ON sc.user_id = u.user_id
LEFT JOIN app.v_user_total_points tp ON tp.user_id = u.user_id;

---

CREATE OR REPLACE VIEW app.v_user_quest_history AS
SELECT
  qa.award_id,
  qa.user_id,
  qa.as_of_date,
  qa.selected_quest,
  qa.reward_points,
  qa.created_at,
  string_agg(qai.quest_id, '|' ORDER BY qai.quest_id)
    FILTER (WHERE qai.status = 'TRIGGERED')  AS triggered_quests,
  string_agg(qai.quest_id, '|' ORDER BY qai.quest_id)
    FILTER (WHERE qai.status = 'SUPPRESSED') AS suppressed_quests
FROM app.quest_awards qa
JOIN app.quest_award_items qai ON qai.award_id = qa.award_id
GROUP BY qa.award_id, qa.user_id, qa.as_of_date, qa.selected_quest, qa.reward_points, qa.created_at;

--- 

CREATE OR REPLACE VIEW app.v_badge_thresholds AS
SELECT
  b.badge_id,
  b.badge_name,
  b.level,
  b.condition,
  NULLIF( (regexp_match(b.condition, '(\d+)'))[1], '' )::int AS threshold_points
FROM app.badges b;

---

CREATE OR REPLACE VIEW app.v_user_eligible_badges AS
SELECT
  utp.user_id,
  bt.badge_id,
  bt.badge_name,
  bt.level,
  utp.total_points,
  bt.threshold_points
FROM app.v_user_total_points utp
JOIN app.v_badge_thresholds bt
  ON bt.threshold_points IS NOT NULL
 AND utp.total_points >= bt.threshold_points;

---

CREATE OR REPLACE VIEW app.v_user_quest_history AS
SELECT
  qa.award_id,
  qa.user_id,
  qa.as_of_date,
  qa.selected_quest,
  qa.reward_points,
  qa.created_at,
  string_agg(qai.quest_id, '|' ORDER BY qai.quest_id)
    FILTER (WHERE qai.status = 'TRIGGERED')  AS triggered_quests,
  string_agg(qai.quest_id, '|' ORDER BY qai.quest_id)
    FILTER (WHERE qai.status = 'SUPPRESSED') AS suppressed_quests
FROM app.quest_awards qa
JOIN app.quest_award_items qai ON qai.award_id = qa.award_id
GROUP BY qa.award_id, qa.user_id, qa.as_of_date, qa.selected_quest, qa.reward_points, qa.created_at;

--- Badge condition’dan threshold çıkar (view)

CREATE OR REPLACE VIEW app.v_badge_thresholds AS
SELECT
  b.badge_id,
  b.badge_name,
  b.level,
  b.condition,
  NULLIF((regexp_match(b.condition, '(\d+)'))[1], '')::int AS threshold_points
FROM app.badges b;

---Hak eden kullanıcı-badge eşleşmeleri (view) OLMADI BAK TEKRARDAN

CREATE OR REPLACE VIEW app.v_user_eligible_badges AS
SELECT
  utp.user_id,
  bt.badge_id,
  bt.badge_name,
  bt.level,
  utp.total_points,
  bt.threshold_points
FROM app.v_user_total_points utp
JOIN app.v_badge_thresholds bt
  ON bt.threshold_points IS NOT NULL
 AND utp.total_points >= bt.threshold_points;

CREATE OR REPLACE VIEW app.v_badge_thresholds AS
SELECT
  b.badge_id,
  b.badge_name,
  b.level,
  b.condition,
  (regexp_match(b.condition, '>=\s*(\d+)'))[1]::int AS threshold_points
FROM app.badges b;

CREATE OR REPLACE VIEW app.v_user_eligible_badges AS
SELECT
  utp.user_id,
  bt.badge_id,
  bt.badge_name,
  bt.level,
  utp.total_points,
  bt.threshold_points
FROM app.v_user_total_points utp
JOIN app.v_badge_thresholds bt
  ON utp.total_points >= bt.threshold_points;

----

CREATE OR REPLACE VIEW app.v_user_notifications AS
SELECT
  n.notification_id,
  n.user_id,
  n.channel,
  n.message,
  n.sent_at
FROM app.notifications n;
