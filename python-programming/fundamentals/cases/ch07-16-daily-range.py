# 7.3절 «따라 하기» 1단계 work/daily_range.py 입니다 («예측해 보기»의 코드와 같습니다).
def daily_range(low, high):
    return high - low


bj = daily_range(-1.5, 7.8)
sd = daily_range(-1.0, 4.8)
print(f"{bj:.1f} {sd:.1f}")
print(bj > sd)
print(f"{daily_range(2.6, 7.6):.1f}")
