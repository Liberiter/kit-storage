# 12.1절 «흔한 실수» — 모듈 이름 없이 read_rows 를 부르다 멈추는 work/sd_report.py 의 화면입니다 (NameError).
# 여러분이 work/ 에 만드는 파일들과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
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
""",
    "work/sd_report.py": """import rain_steps

sd_records = [
    "SD|2025-11-01|-1.0|4.8|0.0|흐림",
    "SD|2025-11-02|-1.3|4.7|0.0|흐림",
    "SD|2025-11-03|2.3|8.9|0.0|구름많음",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
    "SD|2025-11-06|-0.0|8.6|0.0|구름많음",
    "SD|2025-11-07|1.2|10.0|0.0|구름많음",
    "SD|2025-11-08|-1.4|5.9|0.0|흐림",
    "SD|2025-11-09|1.3|7.3|0.0|맑음",
    "SD|2025-11-10|-2.7|5.4|0.0|흐림",
]
rows = read_rows(sd_records)
rainy = pick_rainy(rows)
print_report(rows, rainy, total_rain(rainy))
""",
}
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 work/ 의 그 파일을 실행하는
# 것이고, "ruff" 는 실습 폴더의 설정 파일을 주어 그 하위 명령을 부르는 것입니다.
COMMANDS = [["python", "work/sd_report.py"]]

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    for name, source in FILES.items():
        with open(os.path.join(tmp, name), "w", encoding="utf-8") as f:
            f.write(source)
    code = 0
    for args in COMMANDS:
        if args[0] == "python":
            command = [sys.executable, *args[1:]]
        else:
            config = ["--config", os.path.join(KIT, "pyproject.toml"), "--no-cache"]
            command = [RUFF, args[1], *config, *args[2:]]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        screen = done.stdout + done.stderr
        for root in (os.path.realpath(tmp), tmp):
            screen = screen.replace(root + os.sep, "")
        print(screen, end="")
        code = done.returncode
sys.exit(code)
