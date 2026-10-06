# 10.2절 «왜 그럴까요» — 이름이 뜻을 가린 계산과 이름이 뜻을 드러낸 계산을 견주는 work/swap.py 의 화면입니다.
d1 = [-1.5, 1.6, 0.3]
d2 = [7.8, 10.9, 8.4]
print([round(a - b, 1) for a, b in zip(d1, d2)])
lows = [-1.5, 1.6, 0.3]
highs = [7.8, 10.9, 8.4]
print([round(high - low, 1) for low, high in zip(lows, highs)])
