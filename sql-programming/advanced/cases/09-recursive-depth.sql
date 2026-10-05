-- kit smoke: 깊은 계층 — 토론 글타래의 깊이 분포 (재귀 질의)
WITH RECURSIVE t AS (
  SELECT post_id, 1 AS depth FROM discussion_posts WHERE parent_id IS NULL
  UNION ALL
  SELECT p.post_id, t.depth + 1 FROM discussion_posts p JOIN t ON p.parent_id = t.post_id
)
SELECT max(depth) AS max_depth, count(*) FILTER (WHERE depth >= 20) AS posts_at_depth_20_plus, count(*) AS posts
  FROM t;
