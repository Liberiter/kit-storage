# 복습 exercise 2 해설의 모범답안 work/review2.py 입니다 (지문의 요구 화면과 같은 출력).
def clean_code(text):
    return text.strip().upper()


def sky_between(sky, first, last):
    return sky[first - 1 : last]


lines = [
    " bj | 2025-11-01 | 0.0",
    "Sd|2025-11-01|0.0",
    "nm | 2025-11-01|0.0",
    " HG|2025-11-01 | 0.0",
    "mr|2025-11-01|0.0",
    "gs | 2025-11-01 | 0.0",
]
codes = []
for line in lines:
    codes.append(clean_code(line.split("|")[0]))
joined = ", ".join(codes)
print(f"11월 1일 수첩 코드: {joined}")
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
print(f"바람재 1~7일 하늘: {sky_between(bj_sky, 1, 7)}")
print(f"바람재 22~23일 하늘: {sky_between(bj_sky, 22, 23)}")
