-- 9장 주장 케이스 (불리언) — 본문에 코드 블록으로 등장하지 않는다.
-- 뒷받침하는 자리: 9.3 «practice» 2 해설의 「1번과 102번, 34번과 218번은 태그의 차례까지 똑같습니다」와
-- 「원소와 그 차례가 모두 같아야 같은 배열」 (원소가 같아도 차례가 다르면 같지 않다)
SELECT '1번과 102번 책의 태그가 같은가' AS 주장,
       (SELECT tags FROM book_meta WHERE book_id = 1)
       = (SELECT tags FROM book_meta WHERE book_id = 102) AS 실측값
UNION ALL
SELECT '34번과 218번 책의 태그가 같은가',
       (SELECT tags FROM book_meta WHERE book_id = 34)
       = (SELECT tags FROM book_meta WHERE book_id = 218)
UNION ALL
SELECT '차례만 다른 두 배열이 같은가',
       ARRAY['여행', '사진많음'] = ARRAY['사진많음', '여행'];
