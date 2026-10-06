# 9.2절 «따라 하기» 5단계 — zip() 과 enumerate() 로 짝지어 훑는 work/zip_days.py 입니다.
bj_low = [-1.5, 1.6, 0.3, 1.3, 1.6]
bj_high = [7.8, 10.9, 8.4, 9.3, 10.4]
for pair in zip(bj_low, bj_high):
    print(pair)
for day, high in enumerate(bj_high, start=1):
    print(f"11월 {day}일 최고 {high}도")
