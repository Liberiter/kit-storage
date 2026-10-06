# «도전하기» problem 2 — 모범답안의 맨 위 세 줄을 갈숲 11월 4일로 바꾼 화면입니다 (지문의 둘째 요구 화면).
label = "갈숲 11월 4일"
low = 0.9
rain = 2.0
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
