-- 9장 본문이 인용하는 world 데이터 주장(글자). 각 행이 "주장 → 실측값(글자)" 쌍이다.
-- 수치 주장(ch09-53-world-claims-counts)과 값의 타입이 달라 케이스를 나눴다
-- (pipeline "주장 케이스" — 날짜·글자는 -text, 정수는 -counts).
--  · 9.1 따라 하기 6단계: 인용한 리뷰 문구 「배송이 빨랐어요」가 world에 실재하는가.
--    본문은 여덟 가지 문구의 목록을 싣지 않으므로 학습자가 출력에서 셀 수 없고
--    (D-033의 면제 대상이 아니다), 인용 문구는 어느 출력 블록에도 나타나지 않는다.
SELECT t.claim, t.value
FROM (
  SELECT 1 AS ord, '6단계가 인용한 리뷰 문구' AS claim,
         (SELECT DISTINCT comment FROM reviews
           WHERE comment = '배송이 빨랐어요') AS value
  UNION ALL SELECT 2, 'reviews.comment의 서로 다른 값 (가나다순)',
         (SELECT string_agg(c, ' / ' ORDER BY c)
            FROM (SELECT DISTINCT comment AS c FROM reviews
                   WHERE comment IS NOT NULL) AS d)
) AS t
ORDER BY t.ord;
