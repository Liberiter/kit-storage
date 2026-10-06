# problem 1 해설 — 모범답안 work/trace.py 입니다.
def without_trace(amounts, limit=0.5):
    fixed = amounts[:]
    for index, amount in enumerate(fixed):
        if amount < limit:
            fixed[index] = 0.0
    return fixed


def wet_count(amounts):
    count = 0
    for amount in amounts:
        if amount > 0:
            count = count + 1
    return count


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
fixed = without_trace(bj_rain)
print("보정한 목록:", fixed)
print(f"보정한 비 온 날: {wet_count(fixed)}일")
print(f"원래 목록의 합계: {sum(bj_rain):.1f}mm")
