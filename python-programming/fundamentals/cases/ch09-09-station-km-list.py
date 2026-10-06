# 9.2절 «문제 상황» — 관측소 묶음을 리스트로 두어 함수가 고도를 고쳐 버리는 work/station_km.py 입니다.
def print_km(station):
    station[2] = station[2] / 1000
    print(f"{station[1]} 고도: {station[2]}km")


bj = ["BJ", "바람재", 612]
print_km(bj)
print(f"{bj[1]} 고도: {bj[2]}m")
