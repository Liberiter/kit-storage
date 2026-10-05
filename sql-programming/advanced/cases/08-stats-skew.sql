-- kit smoke: 편중 분포의 통계 — 가장 흔한 값 목록과 그 빈도 (통계를 전체 행으로 받아 구축마다 같다)
SELECT attname, n_distinct, most_common_vals::text AS mcv, most_common_freqs::text AS freqs
  FROM pg_stats
 WHERE schemaname = 'public' AND tablename = 'sales' AND attname IN ('status', 'channel')
 ORDER BY attname;
