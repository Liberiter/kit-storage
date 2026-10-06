# 9.1절 practice 1 풀이 — 사본에 최댓값을 덧붙이는 work/with_max.py 입니다.
def print_with_max(amounts):
    row = amounts[:]
    row.append(max(amounts))
    print("강수량과 최댓값:", row)


sd_rain = [0.0, 0.0, 0.0, 8.5, 4.1, 0.0, 0.0, 0.0, 0.0, 0.0]
print_with_max(sd_rain)
print("원소 수:", len(sd_rain))
