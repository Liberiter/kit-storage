# 7.2절 «따라 하기» 2단계 — 리스트를 돌며 함수를 부르는 work/range_days.py 입니다.
def show_range(name, low, high):
    print(f"{name} 일교차: {high - low:.1f}도")


bj_low = [-1.5, 1.6, 0.3, 1.3, 1.6]
bj_high = [7.8, 10.9, 8.4, 9.3, 10.4]
for index in range(len(bj_low)):
    show_range(f"바람재 11월 {index + 1}일", bj_low[index], bj_high[index])
