-- 3장 본문이 인용하는 날짜 주장. 각 행이 "주장 → 실측값(날짜 글자)" 쌍이다.
-- 값이 정수가 아니라 날짜라 수치 주장(ch03-42-world-claims-counts)에서 나눴다
-- (pipeline "주장 케이스" — 값의 타입이 섞이면 케이스를 나눈다). 본문의 출력
-- 블록이 쓰는 표기 그대로 YYYY-MM-DD 글자로 뽑아 바로 대조할 수 있게 한다.
--  · 3장 exercise 3 지문: "책숲의 책은 1998년부터 2026년까지 걸쳐 있습니다"
--  · 4장 4.1 practice 2: "맨 위가 2026년 6월 18일" (= 가장 늦은 출간일)
--  · 4장 exercise 2 해설: "가장 오래된 책은 1998년 1월 19일에 나왔습니다"
--    (= 가장 이른 출간일). 4장의 두 자리는 입력이 이 케이스와 똑같으므로
--    별도 케이스를 만들지 않았다 (검증 케이스 규약 — 입력이 같으면 같은 케이스다).
SELECT '가장 이른 출간일' AS claim,
       (SELECT CAST(min(published_date) AS text) FROM books) AS value
UNION ALL
SELECT '가장 늦은 출간일', (SELECT CAST(max(published_date) AS text) FROM books);
