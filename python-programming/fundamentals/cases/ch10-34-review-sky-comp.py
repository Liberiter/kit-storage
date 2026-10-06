# 복습 exercise 2 해설 — 4장 4.1절 «따라 하기» 3단계를 내포로 다시 쓴 모범답안 work/review2.py 의 화면입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
wet = [sky for sky in bj_sky if sky == "비" or sky == "눈"]
clear = [sky for sky in bj_sky if sky == "맑"]
print(f"바람재 11월 비나 눈이 온 날: {len(wet)}일")
print(f"바람재 11월 맑은 날: {len(clear)}일")
