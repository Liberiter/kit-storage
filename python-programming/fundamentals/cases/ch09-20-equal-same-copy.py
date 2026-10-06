# 9.3절 «문제 상황» — == 로는 별칭과 사본이 갈리지 않는 work/same_or_copy.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8]
same = bj_rain
backup = bj_rain[:]
print(same == bj_rain, backup == bj_rain)
bj_rain.append(0.0)
print(same == bj_rain, backup == bj_rain)
