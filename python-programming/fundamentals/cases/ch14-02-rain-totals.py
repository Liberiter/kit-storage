# 14.1절 «따라 하기» 2단계 — 기록 파일 180줄로 관측소별 강수량 합계를 내는 work/rain_totals.py 의 화면입니다.
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써 두고, 실습 폴더를 실행 자리로 삼아
# 그 파일을 실행합니다(실습 폴더에서 uv run python work/... 로 실행할 때와 같습니다 — 파일 안의 data/·out/ 같은
# 상대 경로가 실습 폴더를 기준으로 풀립니다). 화면에 찍힌 전체 경로에서 임시 폴더 부분을 떼어 냅니다. 본문은
# 실습 폴더 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/rain_totals.py": """with open("data/readings.txt", encoding="utf-8") as records_file:
    rows = [line.strip().split("|") for line in records_file]
print("읽은 줄:", len(rows))
totals = {}
for cells in rows:
    totals[cells[0]] = totals.get(cells[0], 0.0) + float(cells[4])
for code, total in totals.items():
    print(code, round(total, 1))
""",
}
SETUP = []
COMMANDS = [["python", "work/rain_totals.py"]]

# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 work/ 의 그 파일을 이 케이스를 실행하는 파이썬으로,
# "cat" 은 실습 폴더의 그 파일 내용을 그대로, "ruff" 는 실습 폴더의 pyproject.toml 을 설정으로 주어 부릅니다.
# SETUP 은 화면을 싣지 않는 앞 단계(본문이 «앞 단계에 이어서»라고 밝힌 상태)를 만드는 명령입니다.
KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")


def run(args, tmp):
    if args[0] == "cat":
        with open(os.path.join(KIT, args[1]), encoding="utf-8") as f:
            return f.read(), 0
    if args[0] == "python":
        command = [sys.executable, os.path.join(tmp, args[1]), *args[2:]]
        done = subprocess.run(command, cwd=KIT, capture_output=True, text=True)
    else:
        config = ["--config", os.path.join(KIT, "pyproject.toml"), "--no-cache"]
        command = [RUFF, args[1], *config, *args[2:]]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
    screen = done.stdout + done.stderr
    for root in (os.path.realpath(tmp), tmp):
        screen = screen.replace(root + os.sep, "")
    return screen, done.returncode


with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    for name, source in FILES.items():
        with open(os.path.join(tmp, name), "w", encoding="utf-8") as f:
            f.write(source)
    for args in SETUP:
        run(args, tmp)
    code = 0
    for args in COMMANDS:
        screen, code = run(args, tmp)
        print(screen, end="")
sys.exit(code)
