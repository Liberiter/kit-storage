# 6.1절 «따라 하기» 4단계 — 같은 키로 두 딕셔너리를 잇는 work/high_stations.py 입니다.
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
elevations = {"BJ": 612, "SD": 447, "NM": 158, "HG": 93, "MR": 238, "GS": 355}
for code in elevations:
    if elevations[code] >= 300:
        print(f"{names[code]}({code}): {elevations[code]}m")
