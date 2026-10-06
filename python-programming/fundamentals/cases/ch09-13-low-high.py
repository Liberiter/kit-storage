# 9.2절 «따라 하기» 3단계 — 튜플을 풀어 묶고 값 둘을 돌려받는 work/low_high.py 입니다.
def low_high(values):
    return min(values), max(values)


code, name, elevation = ("BJ", "바람재", 612)
print(code, name, elevation)
bj_low = [-1.5, 1.6, 0.3, 1.3, 1.6, -1.7, -1.8, -1.4, -2.8, -1.3]
pair = low_high(bj_low)
print(pair, type(pair))
lowest, highest = low_high(bj_low)
print(f"{name} 최저기온의 범위: {lowest}~{highest}도")
