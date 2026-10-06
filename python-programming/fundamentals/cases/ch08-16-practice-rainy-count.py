# 8.2절 practice 2 풀이 work/rainy_count.py 입니다 (지문의 요구 화면과 같은 출력).
def rainy_count(amounts):
    if len(amounts) == 0:
        return 0
    elif amounts[0] > 0:
        return 1 + rainy_count(amounts[1:])
    else:
        return rainy_count(amounts[1:])


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
sd_rain = [0.0, 0.0, 0.0, 8.5, 4.1, 0.0, 0.0, 0.0, 0.0, 0.0]
print(f"바람재 비 온 날: {rainy_count(bj_rain)}일")
print(f"솔등 비 온 날: {rainy_count(sd_rain)}일")
