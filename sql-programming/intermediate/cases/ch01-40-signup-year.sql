-- 1장 «도전하기» problem 1: 가입 연도별 고객 요약
SELECT
    to_char(signup_date, 'YYYY') AS 가입연도,
    count(*) AS 고객수,
    count(*) FILTER (WHERE marketing_opt_in) AS 수신동의,
    count(*) FILTER (WHERE birth_date IS NULL) AS "생일 미기재",
    round(100.0 * count(*) FILTER (WHERE marketing_opt_in) / count(*), 1)
        AS "동의율(%)"
FROM customers
GROUP BY to_char(signup_date, 'YYYY')
ORDER BY 가입연도;
