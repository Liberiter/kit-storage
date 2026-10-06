# 6.1절 practice 1 풀이 work/sky_counts.py 입니다 (지문의 요구 화면과 같은 출력).
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
counts = {}
for sky in bj_sky:
    if sky in counts:
        counts[sky] = counts[sky] + 1
    else:
        counts[sky] = 1
for sky in counts:
    print(f"{sky}: {counts[sky]}일")
