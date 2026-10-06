# 6.2절 practice 1 풀이 work/sd_late_kinds.py 입니다 (지문의 요구 화면과 같은 출력).
sd_sky = "흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑"
late = set(sd_sky[20:])
has_rain = "비" in late
print(f"솔등 하순 하늘 가짓수: {len(late)}")
print(f"솔등 하순 하늘: {sorted(late)}")
print(f"하순에 비가 온 날이 있었나: {has_rain}")
