# 4.2절 «왜 그럴까요» — 한 달을 둘로 나눈 work/halves.py 입니다.
first_half = 0
for _ in range(1, 16):
    first_half = first_half + 1
second_half = 0
for _ in range(16, 31):
    second_half = second_half + 1
print(f"range(1, 16): {first_half}번, range(16, 31): {second_half}번")
print(f"합쳐서 {first_half + second_half}번")
