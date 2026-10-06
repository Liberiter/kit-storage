# 9.3절 practice 1 풀이 — get() 과 is None 으로 고도를 찾는 work/get_elevation.py 입니다.
elevations = {"BJ": 612, "SD": 447, "NM": 158, "HG": 93, "MR": 238, "GS": 355}
for code in ["GS", "PT", "MR"]:
    elevation = elevations.get(code)
    if elevation is None:
        print(f"{code}: 고도를 모릅니다")
    else:
        print(f"{code}: {elevation}m")
