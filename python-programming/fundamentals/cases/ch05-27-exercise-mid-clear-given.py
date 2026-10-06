# «연습하기» exercise 3 — 지문의 work/ex3.py (고치기 전) 입니다.
sd_sky = "흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑"
middle = sd_sky[10:19]
clear_days = 0
for sky in middle:
    if sky == "맑":
        clear_days = clear_days + 1
print(f"솔등 중순(11~20일) 맑은 날: {clear_days}일")
