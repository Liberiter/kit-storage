# 7.3절 «따라 하기» 2단계 — 돌려받은 값으로 견주는 work/range_max.py 입니다.
def daily_range(low, high):
    return high - low


names = ["바람재", "솔등", "너미", "하곡", "물레", "갈숲"]
lows = [-1.5, -1.0, 2.6, 1.0, 2.1, 0.3]
highs = [7.8, 4.8, 7.6, 8.2, 11.4, 5.9]
most = 0
for index in range(len(names)):
    gap = daily_range(lows[index], highs[index])
    print(f"{names[index]} 일교차: {gap:.1f}도")
    if gap > most:
        most = gap
print(f"가장 큰 일교차: {most:.1f}도")
