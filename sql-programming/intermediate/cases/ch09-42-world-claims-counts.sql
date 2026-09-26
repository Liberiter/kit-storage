-- 9장 주장 케이스 (정수) — 본문에 코드 블록으로 등장하지 않는다.
-- 출력 블록에서 여러분이 셀 수 없는 수치 주장을 한 표에 모아 고정한다 (D-017·D-021).
-- UNION ALL 의 줄 차례는 보장되지 않으므로(병렬 실행) 주장 이름 차례로 늘어놓는다.
-- 뒷받침하는 자리:
--   page_views 의 행 199220 → 9.2 «흔한 실수» 1의 「거의 모든 조회가 10초를 넘는다고」(199146 과 견줄 전체)
--   방문자 시간대 5가지 → 9.1 «왜 그럴까요»의 「다섯 곳의 시간대에서 들어옵니다」
--   UTC 5월 31일 조회 가운데 서울 날짜로 6월 1일인 것 434, 서울 시각 9시 이후인 것 0
--     → 9.1 «따라 하기» 3단계의 「서울 시계로는 6월 1일 새벽부터 아침 9시 전까지의 조회」
--   UTC 6월 1일 조회 가운데 서울 날짜로 6월 2일인 것 424 → 9.1 «따라 하기» 3단계의
--     「UTC 6월 1일의 늦은 시각 조회는 서울 날짜로 6월 2일이라 빠졌지요」
--   utm 키의 유무와 광고 유입 여부가 어긋나는 조회 0 → 9.2 «따라 하기» 3단계의 「광고로 들어온
--     조회에만 캠페인 이름을 적습니다」, «도전하기» problem 2 채점 포인트의 「이 world에서는 같은 조회」
--   네 키(device·referrer·dwell_ms·scroll_pct) 가운데 하나라도 없는 조회 0 → 9.2 «왜 그럴까요»의
--     「모든 조회에 있고」, «복습 exercise» 3 채점 포인트의 「이미 있는 행이 모두 두 키를 가지고」
--   교양과학 태그가 붙은 책 29, 그 가운데 과학이 아닌 책 0, 교양과 교양과학이 함께 붙은 책 0
--     → 9.3 «따라 하기» 2단계의 「「교양과학」 태그가 붙은 과학책까지 잡았습니다」(46 = 17 + 29)
--   분류와 첫 태그의 짝 8, books 에 쓰인 분류 8 → 9.3 «왜 그럴까요»의 「첫 태그가 분류마다 정해진 대표 태그」
--   book_meta 에서 tags 를 보는 CHECK 1 → 9.3 «왜 그럴까요»의 「이 칸의 CHECK가 보는 것은 원소의 개수」
--   public 에서 이름에 tag 가 든 표 0 → 9.3 «왜 그럴까요»의 「태그 이름을 관리하는 표는 없습니다」
--   로스앤젤레스 조회 가운데 UTC와 7시간 차이가 아닌 것 0 → 9.1 «왜 그럴까요»의 「책숲 로그(6~8월)의
--     로스앤젤레스 방문은 모두 여름이라 7시간 차이」, «흔한 실수» 1의 「6~8월의 로스앤젤레스는 UTC보다 7시간 늦으므로」
--   해외여행 태그가 붙은 책 16, 국내여행·해외여행이 붙고 여행은 없는 책 0
--     → «연습하기» exercise 4 채점 포인트의 「「국내여행」·「해외여행」이 붙은 책에는 늘 「여행」도 함께」
SELECT 'page_views 의 행 수' AS 주장, count(*) AS 실측값 FROM page_views
UNION ALL
SELECT '방문자 시간대 가짓수', count(DISTINCT client_tz) FROM page_views
UNION ALL
SELECT 'UTC 5월 31일 조회 중 서울 날짜 6월 1일', count(*)
FROM page_views
WHERE CAST(viewed_at AS date) = '2026-05-31'
    AND CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) = '2026-06-01'
UNION ALL
SELECT 'UTC 5월 31일 조회 중 서울 시각 9시 이후', count(*)
FROM page_views
WHERE CAST(viewed_at AS date) = '2026-05-31'
    AND to_char(viewed_at AT TIME ZONE 'Asia/Seoul', 'HH24') >= '09'
UNION ALL
SELECT 'UTC 6월 1일 조회 중 서울 날짜 6월 2일', count(*)
FROM page_views
WHERE CAST(viewed_at AS date) = '2026-06-01'
    AND CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) = '2026-06-02'
UNION ALL
SELECT 'utm 유무와 광고 유입이 어긋나는 조회 수', count(*)
FROM page_views
WHERE (context ? 'utm') <> (context ->> 'referrer' = 'ad')
UNION ALL
SELECT '네 키 가운데 하나라도 없는 조회 수', count(*)
FROM page_views
WHERE NOT (context ? 'device' AND context ? 'referrer'
           AND context ? 'dwell_ms' AND context ? 'scroll_pct')
UNION ALL
SELECT '교양과학 태그가 붙은 책 수', count(*)
FROM book_meta WHERE tags @> ARRAY['교양과학']
UNION ALL
SELECT '교양과학 태그가 붙은 과학 아닌 책 수', count(*)
FROM book_meta INNER JOIN books ON books.book_id = book_meta.book_id
WHERE book_meta.tags @> ARRAY['교양과학'] AND books.category <> '과학'
UNION ALL
SELECT '교양과 교양과학이 함께 붙은 책 수', count(*)
FROM book_meta WHERE tags @> ARRAY['교양', '교양과학']
UNION ALL
SELECT '분류와 첫 태그의 짝 수', count(*)
FROM (SELECT DISTINCT books.category, book_meta.tags[1]
      FROM book_meta INNER JOIN books ON books.book_id = book_meta.book_id) AS pairs
UNION ALL
SELECT 'books 에 쓰인 분류 수', count(DISTINCT category) FROM books
UNION ALL
SELECT 'book_meta 에서 tags 를 보는 CHECK 수', count(*)
FROM pg_constraint
WHERE conrelid = 'book_meta'::regclass AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%tags%'
UNION ALL
SELECT 'public 에서 이름에 tag 가 든 표 수', count(*)
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE '%tag%'
UNION ALL
SELECT '로스앤젤레스 조회 중 UTC와 7시간 차이가 아닌 것', count(*)
FROM page_views
WHERE client_tz = 'America/Los_Angeles'
    AND (viewed_at AT TIME ZONE 'UTC') - (viewed_at AT TIME ZONE client_tz)
        <> CAST('7 hours' AS interval)
UNION ALL
SELECT '해외여행 태그가 붙은 책 수', count(*)
FROM book_meta WHERE tags @> ARRAY['해외여행']
UNION ALL
SELECT '국내여행·해외여행이 붙고 여행은 없는 책 수', count(*)
FROM book_meta
WHERE tags && ARRAY['국내여행', '해외여행'] AND NOT tags @> ARRAY['여행']
ORDER BY 주장;
