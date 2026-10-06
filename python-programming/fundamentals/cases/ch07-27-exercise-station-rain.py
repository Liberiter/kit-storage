# exercise 4 해설의 모범답안 work/ex4.py 입니다 (지문의 요구 화면과 같은 출력).
def average(amounts):
    return sum(amounts) / len(amounts)


def wet_count(amounts, limit=0.1):
    count = 0
    for amount in amounts:
        if amount >= limit:
            count = count + 1
    return count


def report(name, amounts):
    print(f"{name}: 평균 {average(amounts):.2f}mm, 비 온 날 {wet_count(amounts)}일")


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
sd_rain = [0.0, 0.0, 0.0, 8.5, 4.1, 0.0, 0.0, 0.0, 0.0, 0.0]
nm_rain = [0.0, 0.0, 0.0, 8.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
report("바람재", bj_rain)
report("솔등", sd_rain)
report("너미", nm_rain)
