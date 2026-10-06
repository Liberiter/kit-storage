# 7.3절 practice 1 풀이 work/snow_compare.py 입니다 (지문의 요구 화면과 같은 출력).
def count_days(sky, target="눈"):
    count = 0
    for letter in sky:
        if letter == target:
            count = count + 1
    return count


bj_snow = count_days("흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구")
sd_snow = count_days("흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑")
print(f"눈 온 날 — 바람재 {bj_snow}일, 솔등 {sd_snow}일")
if bj_snow > sd_snow:
    print(f"바람재가 {bj_snow - sd_snow}일 더 많습니다")
elif bj_snow < sd_snow:
    print(f"솔등이 {sd_snow - bj_snow}일 더 많습니다")
else:
    print("두 곳이 같습니다")
