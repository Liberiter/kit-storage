# 6.2절 «따라 하기» 1단계 work/sky_kinds.py 입니다 (6.2절 «예측해 보기»의 코드와 같습니다).
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
kinds = set(bj_sky)
print(len(bj_sky), len(kinds))
print(sorted(kinds))
print("비" in kinds, "비" not in kinds)
