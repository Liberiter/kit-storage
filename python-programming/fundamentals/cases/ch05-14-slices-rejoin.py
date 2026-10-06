# 5.2절 «왜 그럴까요» — work/rejoin.py 입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
early = bj_sky[:10]
middle = bj_sky[10:20]
late = bj_sky[20:]
print(len(early), len(middle), len(late))
print(early + middle + late == bj_sky)
