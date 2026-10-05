-- kit smoke: 관찰 도구 — sales 의 첫 페이지 머리와 줄 포인터 (페이지 자리가 구축마다 같다)
SELECT lower, upper, special, pagesize FROM page_header(get_raw_page('sales', 0));
SELECT count(*) AS line_pointers, min(lp_len) AS min_len, max(lp_len) AS max_len
  FROM heap_page_items(get_raw_page('sales', 0));
