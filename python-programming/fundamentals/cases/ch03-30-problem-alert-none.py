# «도전하기» problem 1 — 모범답안의 맨 위 세 줄을 너미 11월 22일로 바꾼 화면입니다 (지문의 셋째 요구 화면).
name = "너미"
low = 1.4
rain = 8.6
print(f"[{name}] 최저 {low:.1f}도, 강수 {rain:.1f}mm")
if low <= 0 and rain > 0:
    print("경보: 영하에 강수가 있었습니다. 길이 얼 수 있습니다.")
elif low <= 0:
    print("주의: 영하입니다.")
else:
    print("알림 없음")
