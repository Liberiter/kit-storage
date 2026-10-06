# «도전하기» problem 1 — 모범답안 work/ice_board.py (솔등 11월 14일)의 화면입니다.
# 지문의 첫째 요구 화면과 해설의 출력 블록이 이 화면입니다.
name = "솔등"
low = 0.0
rain = 4.2
print(f"[{name}] 최저 {low:.1f}도, 강수 {rain:.1f}mm")
if low <= 0 and rain > 0:
    print("경보: 영하에 강수가 있었습니다. 길이 얼 수 있습니다.")
elif low <= 0:
    print("주의: 영하입니다.")
else:
    print("알림 없음")
