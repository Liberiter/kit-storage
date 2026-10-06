# runner: reset
# problem 2 해설 — 기록 파일을 관측소별 JSON 으로 옮기는 work/to_json.py 의 화면입니다 (지문의 요구 화면도 같습니다).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써 두고, 실습 폴더를 실행 자리로 삼아
# 그 파일을 실행합니다(실습 폴더에서 uv run python work/... 로 실행할 때와 같습니다 — 파일 안의 data/·out/ 같은
# 상대 경로가 실습 폴더를 기준으로 풀립니다). 화면에 찍힌 전체 경로에서 임시 폴더 부분을 떼어 냅니다. 본문은
# 실습 폴더 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/to_json.py": """import json
import pathlib

text = pathlib.Path("data/readings.txt").read_text(encoding="utf-8")
rows = [line.split("|") for line in text.splitlines()]
stations = {}
for cells in rows:
    if cells[0] not in stations:
        stations[cells[0]] = []
    stations[cells[0]].append(
        {
            "date": cells[1],
            "tmin": float(cells[2]),
            "tmax": float(cells[3]),
            "rain": float(cells[4]),
            "sky": cells[5],
        }
    )
converted = {"month": rows[0][1][:7], "stations": stations}
with open("out/readings_from_txt.json", "w", encoding="utf-8") as out_file:
    json.dump(converted, out_file, ensure_ascii=False, indent=2)
with open("data/readings.json", encoding="utf-8") as json_file:
    original = json.load(json_file)
print(f"관측소 {len(stations)}곳, 기록 {len(rows)}건을 썼습니다.")
print("data/readings.json 과 같은 값인가:", converted == original)
""",
}
SETUP = []
COMMANDS = [["python", "work/to_json.py"]]

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
