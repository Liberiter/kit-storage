# 9.2절 «따라 하기» 1단계 — 튜플을 꺼내고 훑는 work/station_tuple.py 입니다 (9.2절 «예측해 보기»의 코드와 같습니다).
bj = ("BJ", "바람재", 612)
print(bj[1], bj[2])
print(bj[1:], len(bj))
print(612 in bj, "612" in bj)
for item in bj:
    print(item)
