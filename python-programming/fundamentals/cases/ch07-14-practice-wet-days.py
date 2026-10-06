# 7.2절 practice 1 풀이 work/wet_days.py 입니다 (지문의 요구 화면과 같은 출력).
def wet_days(name, amounts, limit=0.1):
    count = 0
    for amount in amounts:
        if amount >= limit:
            count = count + 1
    print(f"{name}: {limit}mm 이상 {count}일")


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
wet_days("바람재", bj_rain)
wet_days("바람재", bj_rain, 1.0)
wet_days("바람재", bj_rain, limit=10.0)
