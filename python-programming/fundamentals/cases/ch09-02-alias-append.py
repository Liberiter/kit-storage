# 9.1절 «따라 하기» 1단계 — 두 이름이 한 리스트를 가리키는 work/alias.py 입니다 (9.1절 «예측해 보기»의 코드와 같습니다).
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8]
same = bj_rain
same.append(0.0)
print(bj_rain)
print(len(bj_rain), len(same))
