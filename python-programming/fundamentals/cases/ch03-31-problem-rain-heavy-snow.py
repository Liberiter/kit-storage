# «도전하기» problem 2 — 모범답안 work/rain_label.py (솔등 11월 13일)의 화면입니다.
# 지문의 첫째 요구 화면과 해설의 출력 블록이 이 화면입니다.
label = "솔등 11월 13일"
low = -1.4
rain = 17.4
if rain > 0 and low <= 0:
    kind = "눈"
elif rain > 0:
    kind = "비"
else:
    kind = "없음"
if kind == "없음":
    print(f"{label}: 강수 없음")
elif rain >= 10:
    print(f"{label}: {kind}, 많음 ({rain:.1f}mm)")
else:
    print(f"{label}: {kind}, 적음 ({rain:.1f}mm)")
