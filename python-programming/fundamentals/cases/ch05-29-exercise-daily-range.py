# «연습하기» exercise 4 — 모범답안 work/ex4.py 입니다(지문이 요구한 화면을 먼저 싣는다).
nm_high = [7.6, 10.8, 7.4, 9.8, 12.0, 7.1, 9.8, 10.7, 8.3, 7.5]
nm_low = [2.6, 1.6, 2.4, 3.7, 3.3, -0.5, 2.6, 2.5, 1.0, -0.5]
widest = 0
widest_day = 0
for day in range(1, 11):
    spread = nm_high[day - 1] - nm_low[day - 1]
    if spread > widest:
        widest = spread
        widest_day = day
print(f"너미 상순 일교차가 가장 컸던 날: 11월 {widest_day}일 ({widest:.1f}도)")
