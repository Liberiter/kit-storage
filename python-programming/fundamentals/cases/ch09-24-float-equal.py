# 9.3절 «흔한 실수» — 소수 계산 결과를 == 로 견준 work/float_equal.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
two_days = bj_rain[7] + bj_rain[8]
print(two_days == bj_rain[9])
print(two_days)
print(abs(two_days - bj_rain[9]) < 0.001)
