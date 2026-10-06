# 9.2절 «왜 그럴까요» 첫 블록 — 튜플을 딕셔너리의 키로 쓰는 work/tuple_key.py 입니다.
rain_by_day = {("BJ", "2025-11-04"): 13.6, ("SD", "2025-11-04"): 8.5}
print(rain_by_day[("SD", "2025-11-04")])
key = ("BJ", "2025-11-04")
print(key in rain_by_day, rain_by_day[key])
