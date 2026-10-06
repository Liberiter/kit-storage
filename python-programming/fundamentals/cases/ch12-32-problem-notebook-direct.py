# problem 2 지문·해설 — work/notebook.py 를 직접 실행한 화면입니다 (고치기 전과 고친 뒤가 같아야 합니다 — 이 케이스는 고친 파일).
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
    "work/notebook.py": """def to_amount(text):
    try:
        return float(text)
    except ValueError:
        return None


def day_amounts(lines):
    amounts = [to_amount(line.split("|")[2]) for line in lines]
    return [amount for amount in amounts if amount is not None]


def main():
    print("[확인]", day_amounts(["bj | 2025-11-04 | 3.5", "sd|2025-11-04|3.9"]))


if __name__ == "__main__":
    main()
""",
}
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 work/ 의 그 파일을 실행하는
# 것이고, "ruff" 는 실습 폴더의 설정 파일을 주어 그 하위 명령을 부르는 것입니다.
COMMANDS = [["python", "work/notebook.py"]]

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
