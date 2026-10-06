# 복습 exercise 1 해설 — 모범답안 work/review1.py 입니다. 지문이 요구한 화면을 먼저 싣습니다.
def rainy_mean(amounts, digits=1):
    rainy = [amount for amount in amounts if amount > 0]
    try:
        return round(sum(rainy) / len(rainy), digits)
    except ZeroDivisionError:
        return None


bj = [0.0, 0.0, 9.4, 3.5]
sd = [0.0, 8.8, 3.9]
mr = [0.0, 0.0, 0.0, 0.0]
print("바람재:", rainy_mean(bj))
print("솔등:", rainy_mean(sd, digits=2))
mean = rainy_mean(mr)
if mean is None:
    print("물레: 비 온 날 없음")
else:
    print("물레:", mean)
