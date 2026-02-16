-- Generated split from karısıkquery.sql
-- 03_data_ops_badges_notifications_ledger.sql

-- 1) Ana ödül kayıtları
INSERT INTO app.quest_awards (award_id, user_id, as_of_date, selected_quest, reward_points, created_at)
SELECT award_id, user_id, as_of_date, selected_quest, reward_points, "timestamp"
FROM app.stg_quest_awards;

-- 2) Triggered listesi
INSERT INTO app.quest_award_items (award_id, quest_id, status)
SELECT s.award_id, qid, 'TRIGGERED'
FROM app.stg_quest_awards s,
LATERAL unnest(string_to_array(s.triggered_quests, '|')) AS qid
WHERE COALESCE(s.triggered_quests,'') <> '';

-- 3) Selected
INSERT INTO app.quest_award_items (award_id, quest_id, status)
SELECT award_id, selected_quest, 'SELECTED'
FROM app.stg_quest_awards;

-- 4) Suppressed listesi
INSERT INTO app.quest_award_items (award_id, quest_id, status)
SELECT s.award_id, qid, 'SUPPRESSED'
FROM app.stg_quest_awards s,
LATERAL unnest(string_to_array(s.suppressed_quests, '|')) AS qid
WHERE COALESCE(s.suppressed_quests,'') <> '';

-- Triggered
INSERT INTO app.quest_award_items (award_id, quest_id, status)
SELECT s.award_id, qid, 'TRIGGERED'
FROM app.stg_quest_awards s,
LATERAL unnest(string_to_array(s.triggered_quests, '|')) AS qid
WHERE COALESCE(s.triggered_quests,'') <> '';

-- Selected
INSERT INTO app.quest_award_items (award_id, quest_id, status)
SELECT award_id, selected_quest, 'SELECTED'
FROM app.stg_quest_awards;

-- Suppressed
INSERT INTO app.quest_award_items (award_id, quest_id, status)
SELECT s.award_id, qid, 'SUPPRESSED'
FROM app.stg_quest_awards s,
LATERAL unnest(string_to_array(s.suppressed_quests, '|')) AS qid
WHERE COALESCE(s.suppressed_quests,'') <> '';

---badge_awards tablosuna bas (verilmeyenleri ekle)

INSERT INTO app.badge_awards (user_id, badge_id, awarded_at)
SELECT
  e.user_id,
  e.badge_id,
  NOW()
FROM app.v_user_eligible_badges e
ON CONFLICT (user_id, badge_id) DO NOTHING;

UPDATE app.badges
SET condition = CASE badge_id
  WHEN 'B-01' THEN 'total_points >= 100'
  WHEN 'B-02' THEN 'total_points >= 180'
  WHEN 'B-03' THEN 'total_points >= 200'
END
WHERE badge_id IN ('B-01','B-02','B-03');

INSERT INTO app.badge_awards (user_id, badge_id, awarded_at)
SELECT user_id, badge_id, NOW()
FROM app.v_user_eligible_badges
ON CONFLICT (user_id, badge_id) DO NOTHING;

-----

INSERT INTO app.notifications (notification_id, user_id, channel, message, sent_at)
SELECT
  'N-' || qa.award_id AS notification_id,
  qa.user_id,
  'IN_APP' AS channel,
  'Congrats! You completed "' || q.quest_name || '" and earned +' || qa.reward_points || ' points.' AS message,
  NOW() AS sent_at
FROM app.quest_awards qa
JOIN app.quests q ON q.quest_id = qa.selected_quest
ON CONFLICT (notification_id) DO NOTHING;
