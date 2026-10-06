# 6.2절 «따라 하기» 3단계 — 두 집합을 견주는 work/code_check.py 입니다.
stations = {"BJ", "SD", "NM", "HG", "MR", "GS"}
logged = {"BJ", "GS", "HG", "MR", "NM", "PT", "SD"}
print(sorted(logged - stations))
print(sorted(stations - logged))
print(sorted(logged & stations))
print(len(logged | stations))
