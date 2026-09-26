-- 9장 주장 케이스 (글자) — 본문에 코드 블록으로 등장하지 않는다.
-- UNION ALL 의 줄 차례는 보장되지 않으므로(병렬 실행) 주장 이름 차례로 늘어놓는다.
-- 뒷받침하는 자리: 9.3 «왜 그럴까요»의 「역사 책은 모두 한국사로, 과학 책은 모두 교양과학으로 시작합니다」
-- (분류 안의 첫 태그를 겹침 없이 모은 글자 — 한 가지뿐이면 그 태그 하나가 찍힌다)
-- 방문자 시간대 이름 → 「왜 배우나요」의 「방문자는 로스앤젤레스·런던·도쿄·시드니에서도 들어옵니다」
--   (런던은 본문의 어느 출력 블록에도 찍히지 않는다)
-- 첫 공급 피드의 날짜 → 9.1 «practice» 1의 「첫 피드(feed_date가 2026-08-25인 것)」
-- book_meta 의 기본키 정의 → «도전하기» problem 1 채점 포인트의 「book_meta의 기본키가 book_id」
SELECT '역사 책의 첫 태그' AS 주장, string_agg(DISTINCT book_meta.tags[1], ',') AS 실측값
FROM book_meta INNER JOIN books ON books.book_id = book_meta.book_id
WHERE books.category = '역사'
UNION ALL
SELECT '과학 책의 첫 태그', string_agg(DISTINCT book_meta.tags[1], ',')
FROM book_meta INNER JOIN books ON books.book_id = book_meta.book_id
WHERE books.category = '과학'
UNION ALL
SELECT '방문자 시간대 이름', string_agg(DISTINCT client_tz, ',') FROM page_views
UNION ALL
SELECT '첫 공급 피드의 날짜', CAST(min(feed_date) AS text) FROM supplier_feed
UNION ALL
SELECT 'book_meta 의 기본키 정의', pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'book_meta'::regclass AND contype = 'p'
ORDER BY 주장;
