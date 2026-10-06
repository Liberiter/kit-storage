# 복습 exercise 1 해설 — 모범답안 work/review1.py 입니다.
def widest_day(lows, highs):
    best_day = 0
    best_spread = 0.0
    for day, (low, high) in enumerate(zip(lows, highs), start=1):
        if high - low > best_spread:
            best_day = day
            best_spread = high - low
    return best_day, best_spread


nm_high = [7.6, 10.8, 7.4, 9.8, 12.0, 7.1, 9.8, 10.7, 8.3, 7.5]
nm_low = [2.6, 1.6, 2.4, 3.7, 3.3, -0.5, 2.6, 2.5, 1.0, -0.5]
day, spread = widest_day(nm_low, nm_high)
print(f"너미 상순 일교차가 가장 컸던 날: 11월 {day}일 ({spread:.1f}도)")
