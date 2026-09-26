-- 9장 9.2 «왜 그럴까요»: json 은 적은 글자 그대로, jsonb 는 키 차례를 정리하고 겹친 키는 마지막 값만 둔다
SELECT
    CAST('{"b": 1, "a": 2, "a": 3}' AS json) AS json으로,
    CAST('{"b": 1, "a": 2, "a": 3}' AS jsonb) AS jsonb로;
