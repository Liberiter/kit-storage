# exercise 3 해설 (b) — float() 로 바꿔 넘기게 고친 work/ex3.py 입니다 (지문의 요구 화면과 같은 출력).
def daily_range(low, high):
    return high - low


line = "BJ|2025-11-01|-1.5|7.8|0.0|흐림"
parts = line.split("|")
gap = daily_range(float(parts[2]), float(parts[3]))
print(f"{parts[0]} {parts[1]} 일교차: {gap:.1f}도")
