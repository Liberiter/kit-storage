# exercise 2 해설의 모범답안 work/ex2.py 입니다 (지문의 요구 화면과 같은 출력).
def temp_text(celsius, unit="C"):
    if unit == "F":
        return f"{celsius * 9 / 5 + 32:.1f}°F"
    else:
        return f"{celsius:.1f}°C"


low_c = temp_text(-1.5)
low_f = temp_text(-1.5, "F")
high_c = temp_text(7.8)
high_f = temp_text(7.8, unit="F")
print(f"바람재 11월 1일 최저 {low_c} / {low_f}")
print(f"바람재 11월 1일 최고 {high_c} / {high_f}")
