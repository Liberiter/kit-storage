# runner: reset
# problem 1 해설 — 현장 수첩을 기록 파일과 견주는 work/notebook_check.py 와 cat out/notebook_diff.txt 의 화면입니다
# (지문의 요구 화면도 같습니다).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써 두고, 실습 폴더를 실행 자리로 삼아
# 그 파일을 실행합니다(실습 폴더에서 uv run python work/... 로 실행할 때와 같습니다 — 파일 안의 data/·out/ 같은
# 상대 경로가 실습 폴더를 기준으로 풀립니다). 화면에 찍힌 전체 경로에서 임시 폴더 부분을 떼어 냅니다. 본문은
# 실습 폴더 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/notebook_check.py": """import pathlib


def rain_by_day(text):
    rows = [line.split("|") for line in text.splitlines()]
    return {(cells[0], cells[1]): float(cells[4]) for cells in rows}


def compare(line, rain):
    cells = [cell.strip() for cell in line.split("|")]
    key = (cells[0].upper(), cells[1])
    try:
        noted = float(cells[2])
    except ValueError:
        return "결측", ""
    if key not in rain:
        return "기록 없음", ""
    elif noted == rain[key]:
        return "같음", ""
    else:
        return "다름", f"{key[1]} {key[0]} 수첩 {noted} 기록 {rain[key]}"


rain = rain_by_day(pathlib.Path("data/readings.txt").read_text(encoding="utf-8"))
notebook = pathlib.Path("data/field_log.txt").read_text(encoding="utf-8")
counts = {}
diffs = []
for line in notebook.splitlines():
    kind, detail = compare(line, rain)
    counts[kind] = counts.get(kind, 0) + 1
    if kind == "다름":
        diffs.append(detail)
target = pathlib.Path("out") / "notebook_diff.txt"
target.write_text("\\n".join(diffs) + "\\n", encoding="utf-8")
for kind, count in counts.items():
    print(kind, count)
""",
}
SETUP = []
COMMANDS = [["python", "work/notebook_check.py"], ["cat", "out/notebook_diff.txt"]]

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
