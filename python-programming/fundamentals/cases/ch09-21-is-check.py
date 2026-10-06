# 9.3절 «따라 하기» 1단계 — is 와 is not 으로 같은 객체인지 묻는 work/is_check.py 입니다 (9.3절 «예측해 보기»의 코드와 같습니다).
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8]
same = bj_rain
backup = bj_rain[:]
print(same is bj_rain, backup is bj_rain)
print(backup == bj_rain, backup is not bj_rain)
