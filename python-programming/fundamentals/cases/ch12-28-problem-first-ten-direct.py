# problem 1 해설 첫 화면 — 모범답안 work/first_ten.py 를 직접 실행한 화면입니다.
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
    "work/first_ten.py": """bj_records = [
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


def main():
    print("[확인] 바람재", len(bj_records), "줄, 솔등", len(sd_records), "줄")


if __name__ == "__main__":
    main()
""",
}
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 work/ 의 그 파일을 실행하는
# 것이고, "ruff" 는 실습 폴더의 설정 파일을 주어 그 하위 명령을 부르는 것입니다.
COMMANDS = [["python", "work/first_ten.py"]]

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
