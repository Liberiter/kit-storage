# 복습 exercise 1 해설의 모범답안 work/review1.py 입니다 (지문의 요구 화면과 같은 출력).
def reach_day(amounts, target):
    total = 0
    day = 0
    while total < target and day < len(amounts):
        total = total + amounts[day]
        day = day + 1
    if total >= target:
        return day
    else:
        return 0


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3, 0.0, 0.0, 4.5, 15.1, 0.0]
for target in [10, 20, 50]:
    found = reach_day(bj_rain, target)
    if found > 0:
        print(f"{target}mm 이상 쌓인 날: 11월 {found}일")
    else:
        print(f"{target}mm: 15일 안에 닿지 않습니다")
