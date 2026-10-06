# 13.1절 «따라 하기» 3단계 — 표준 라이브러리 모듈 둘과 12장의 work/rain_steps.py 를 임포트하는
# work/spot_check.py 의 화면입니다. work/rain_steps.py 는 12장 12.2절 «따라 하기» 2단계의 판입니다
# (이 장 본문에는 블록으로 다시 싣지 않습니다).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/rain_steps.py": """def read_rows(records):
    return [line.split("|") for line in records]


def pick_rainy(rows):
    return [cells for cells in rows if float(cells[4]) > 0]


def total_rain(rows):
    return sum([float(cells[4]) for cells in rows])


def print_report(rows, rainy, total):
    print("관측소:", rows[0][0])
    print("읽은 날수:", len(rows))
    print("비 온 날수:", len(rainy))
    print("강수량 합계:", round(total, 1))


def main():
    sample = [
        "BJ|2025-11-03|0.3|8.4|0.0|흐림",
        "BJ|2025-11-04|1.3|9.3|13.6|비",
        "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    ]
    picked = pick_rainy(read_rows(sample))
    print("[확인] 고른 줄:", len(picked))
    print("[확인] 합계:", round(total_rain(picked), 1))


if __name__ == "__main__":
    main()
""",
    "work/spot_check.py": """import random
import statistics

import rain_steps

bj_records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "BJ|2025-11-06|-1.7|7.6|0.0|구름많음",
    "BJ|2025-11-07|-1.8|3.2|0.0|맑음",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    "BJ|2025-11-09|-2.8|5.1|0.2|눈",
    "BJ|2025-11-10|-1.3|7.8|0.3|눈",
]
random.seed(2025)
picked = random.sample(rain_steps.read_rows(bj_records), 3)
for cells in picked:
    print(cells[1], "최고기온", cells[3])
highs = [float(cells[3]) for cells in picked]
print("고른 날 최고기온의 중앙값:", statistics.median(highs))
""",
}
# 화면에 나오는 차례대로 실행하는 파일입니다. 실습 폴더에서 uv run python 으로 실행할 때와
# 같은 파이썬(이 케이스를 실행하는 파이썬)으로, 임시 폴더를 실행 자리로 삼아 부릅니다.
COMMANDS = [["work/spot_check.py"]]

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    for name, source in FILES.items():
        with open(os.path.join(tmp, name), "w", encoding="utf-8") as f:
            f.write(source)
    code = 0
    for args in COMMANDS:
        command = [sys.executable, *args]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        screen = done.stdout + done.stderr
        for root in (os.path.realpath(tmp), tmp):
            screen = screen.replace(root + os.sep, "")
        print(screen, end="")
        code = done.returncode
sys.exit(code)
