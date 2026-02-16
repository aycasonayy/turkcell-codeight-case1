-- checks_and_tests.sql

SELECT *
FROM app.quest_award_items
WHERE award_id='QA-100'
ORDER BY quest_id, status;

SELECT * FROM app.stg_quest_awards LIMIT 5;

SELECT * FROM app.quest_awards LIMIT 5;

SELECT * FROM app.quest_award_items ORDER BY award_id, status LIMIT 20;

SELECT award_id, quest_id, status, COUNT(*)
FROM app.quest_award_items
GROUP BY award_id, quest_id, status
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM app.points_ledger;

SELECT * FROM app.v_leaderboard ORDER BY rank LIMIT 10;

SELECT * 
FROM app.v_user_total_points
ORDER BY total_points DESC, user_id;

SELECT * FROM app.v_user_state ORDER BY user_id;

SELECT *
FROM app.v_user_quest_history
ORDER BY as_of_date, user_id;

SELECT *
FROM app.v_user_quest_history
WHERE user_id='U1'
ORDER BY as_of_date;

SELECT * FROM app.v_badge_thresholds ORDER BY level, badge_id;

SELECT * FROM app.v_user_eligible_badges
ORDER BY user_id, level;

---

SELECT *
FROM app.v_user_total_points
ORDER BY total_points DESC, user_id;

SELECT *
FROM app.v_leaderboard
ORDER BY rank
LIMIT 10;

SELECT *
FROM app.v_user_state
ORDER BY user_id;

SELECT *
FROM app.v_user_quest_history
ORDER BY as_of_date, user_id
LIMIT 20;

SELECT *
FROM app.v_user_quest_history
WHERE user_id = 'U1'
ORDER BY as_of_date;

SELECT * FROM app.v_badge_thresholds ORDER BY level, badge_id;

SELECT * FROM app.v_user_eligible_badges ORDER BY user_id, level;

SELECT badge_id, badge_name, condition, level
FROM app.badges
ORDER BY level, badge_id;

SELECT
  badge_id,
  condition,
  (regexp_match(condition, '(\d+)'))[1] AS extracted_number
FROM app.badges
ORDER BY badge_id;

SELECT
  MIN(total_points) AS min_points,
  MAX(total_points) AS max_points
FROM app.v_user_total_points;

SELECT
  ba.user_id,
  ba.badge_id,
  b.badge_name,
  ba.awarded_at
FROM app.badge_awards ba
JOIN app.badges b ON b.badge_id = ba.badge_id
ORDER BY ba.user_id, ba.awarded_at;

SELECT * FROM app.badge_awards ORDER BY user_id, badge_id;

SELECT *
FROM app.notifications
ORDER BY sent_at DESC
LIMIT 20;

SELECT *
FROM app.notifications
WHERE user_id='U1'
ORDER BY sent_at DESC;

SELECT COUNT(*) FROM app.notifications;

SELECT * FROM app.v_leaderboard ORDER BY rank;

WITH p AS (SELECT as_of_date FROM app.v_as_of_date)
SELECT
  e.date,
  SUM(e.login_count) AS login_count_day
FROM app.activity_events e, p
WHERE e.user_id = 'U1'
  AND e.date BETWEEN (p.as_of_date - INTERVAL '9 days') AND p.as_of_date
GROUP BY e.date
ORDER BY e.date DESC;

SELECT user_id, login_streak_days
FROM app.v_user_state
WHERE user_id = 'U1';

WITH p AS (SELECT as_of_date FROM app.v_as_of_date)
SELECT s.user_id, s.login_count_today, s.login_streak_days
FROM app.v_user_state s, p
WHERE s.login_count_today = 0
ORDER BY s.user_id
LIMIT 10;

---

SELECT * FROM app.v_as_of_date;

WITH p AS (SELECT as_of_date FROM app.v_as_of_date)
SELECT
  d::date AS date,
  COALESCE(SUM(e.login_count),0) AS login_count_day
FROM p
CROSS JOIN generate_series(p.as_of_date - INTERVAL '14 days', p.as_of_date, INTERVAL '1 day') d
LEFT JOIN app.activity_events e
  ON e.user_id='U1' AND e.date = d::date
GROUP BY d::date
ORDER BY date DESC;

SELECT user_id, login_count_today, login_streak_days
FROM app.v_user_state
WHERE user_id='U1';

WITH p AS (SELECT as_of_date FROM app.v_as_of_date),
days AS (
  SELECT gs::date AS d
  FROM p
  CROSS JOIN generate_series(p.as_of_date - INTERVAL '30 days', p.as_of_date, INTERVAL '1 day') gs
),
user_days AS (
  SELECT u.user_id, d.d
  FROM app.users u CROSS JOIN days d
),
daily_login AS (
  SELECT ud.user_id, ud.d,
         COALESCE(SUM(e.login_count),0) AS login_count_day
  FROM user_days ud
  LEFT JOIN app.activity_events e
    ON e.user_id=ud.user_id AND e.date=ud.d
  GROUP BY ud.user_id, ud.d
)
SELECT *
FROM daily_login
WHERE login_count_day = 0
LIMIT 20;

---

SELECT *
FROM app.notifications
ORDER BY sent_at DESC
LIMIT 20;
