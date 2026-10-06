# «연습하기» 복습 exercise 1 해설 — 고친 work/review1.py 입니다.
sd_sky = "흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑"
wet_days = 0
for sky in sd_sky:
    if sky == "비" or sky == "눈":
        wet_days = wet_days + 1
print(f"솔등 11월 비나 눈이 온 날: {wet_days}일 ({wet_days / 30 * 100:.1f}%)")
