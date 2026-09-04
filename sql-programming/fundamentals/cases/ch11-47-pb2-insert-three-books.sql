-- runner: reset
-- problem 2 해설 — 신간 세 권을 넣고 분야별 권수를 다시 센다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES
    ('오늘의 바다 탐험 노트', '강서연', '어린이', 14000, 112, '2026-09-10', 20),
    ('처음 만나는 뇌 사전', '한시우', '과학', 32000, 420, '2026-09-12', 5),
    ('작은 겨울 편지', '오건우', '소설', 15000, 240, '2026-09-15', 9);

SELECT category AS 분야, count(*) AS 권수
FROM books
GROUP BY category
ORDER BY 권수 DESC, 분야;
