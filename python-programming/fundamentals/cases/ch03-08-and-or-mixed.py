# 3.1절 «흔한 실수» 둘째 — and 와 or 를 괄호 없이 섞은 work/frost_mixed.py 입니다.
# 첫째 print 는 괄호 관례를 일부러 어긴 의도된 반례입니다 (cases/README.md 「3장의 의도된 반례」).
sky = "맑음"
low = 4.1
print(sky == "맑음" or sky == "구름많음" and low <= 0)
print((sky == "맑음" or sky == "구름많음") and low <= 0)
