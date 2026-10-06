# 12.2절 «practice» 1 풀이 첫 화면 — 메인 가드를 더한 work/freezing_steps.py 를 직접 실행한 화면입니다.
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
    "work/freezing_steps.py": """def pick_freezing(rows):
    return [cells for cells in rows if float(cells[2]) < 0]


def lowest(rows):
    return min([float(cells[2]) for cells in rows])


def print_freezing(rows, freezing, low):
    print("관측소:", rows[0][0])
    print("읽은 날수:", len(rows))
    print("영하인 날수:", len(freezing))
    print("가장 낮은 최저기온:", low)


def main():
    rows = [
        ["BJ", "2025-11-02", "1.6", "10.9", "0.0", "맑음"],
        ["BJ", "2025-11-07", "-1.8", "3.2", "0.0", "맑음"],
        ["BJ", "2025-11-09", "-2.8", "5.1", "0.2", "눈"],
    ]
    print("[확인] 영하인 줄:", len(pick_freezing(rows)))
    print("[확인] 가장 낮은 값:", lowest(rows))


if __name__ == "__main__":
    main()
""",
}
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 work/ 의 그 파일을 실행하는
# 것이고, "ruff" 는 실습 폴더의 설정 파일을 주어 그 하위 명령을 부르는 것입니다.
COMMANDS = [["python", "work/freezing_steps.py"]]

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
