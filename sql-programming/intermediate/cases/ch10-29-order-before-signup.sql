-- runner: reset
-- 10장 10.3 «practice» 2: 가입일보다 앞선 주문일을 BEFORE 트리거로 막는다 (오류 기대)
CREATE FUNCTION check_order_after_signup()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.order_date < (
        SELECT signup_date
        FROM customers
        WHERE customers.customer_id = NEW.customer_id
    ) THEN
        RAISE EXCEPTION '%번 고객의 가입일보다 앞선 주문일입니다: %',
            NEW.customer_id, NEW.order_date;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER orders_after_signup_check
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION check_order_after_signup();

INSERT INTO orders (customer_id, order_date, status)
VALUES (7, '2026-01-15', '배송준비');
