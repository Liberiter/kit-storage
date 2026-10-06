# 복습 exercise 3 해설 — 모범답안 work/review3.py 입니다.
def rain_stats(amounts, limit=0.0):
    count = 0
    total = 0.0
    for amount in amounts:
        if amount > limit:
            count = count + 1
            total = total + amount
    return count, total


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
wet, total = rain_stats(bj_rain)
print(f"0.0mm 넘게 온 날: {wet}일, 합계 {total:.1f}mm")
wet, total = rain_stats(bj_rain, limit=1.0)
print(f"1.0mm 넘게 온 날: {wet}일, 합계 {total:.1f}mm")
