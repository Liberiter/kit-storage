# 7.3절 «따라 하기» 3단계 첫 블록 — 한 갈래가 돌려주지 않는 work/rain_level.py 입니다.
def rain_level(amount):
    if amount >= 10:
        return "많음"
    elif amount > 0:
        return "조금"


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8]
for amount in bj_rain:
    print(amount, rain_level(amount))
