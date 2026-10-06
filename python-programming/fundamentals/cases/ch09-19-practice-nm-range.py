# 9.2절 practice 1 풀이 — 너미의 최고기온 범위를 내는 work/nm_range.py 입니다.
def low_high(values):
    return min(values), max(values)


code, name, elevation = ("NM", "너미", 158)
nm_high = [7.6, 10.8, 7.4, 9.8, 12.0, 7.1, 9.8, 10.7, 8.3, 7.5]
lowest, highest = low_high(nm_high)
print(f"{name}({code}, {elevation}m) 최고기온의 범위: {lowest}~{highest}도")
