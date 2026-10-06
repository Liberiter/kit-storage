# 9.2절 «따라 하기» 2단계 둘째 블록 — 새 값을 만들어 내는 work/tuple_km.py 입니다.
def print_km(station):
    km = station[2] / 1000
    print(f"{station[1]} 고도: {km}km")


bj = ("BJ", "바람재", 612)
print_km(bj)
print(f"{bj[1]} 고도: {bj[2]}m")
