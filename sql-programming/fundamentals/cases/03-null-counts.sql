-- smoke: COUNT(*) 대 COUNT(열) — NULL 대비 (5·9장 전제)
SELECT count(*) AS all_reviews,
       count(comment) AS with_comment,
       count(*) - count(comment) AS rating_only
  FROM reviews;
