# runner: reset
# 10.3절 «따라 하기» 4단계 — 남은 두 자리를 손으로 고친 broken/untidy_report.py 에 포매터 검사·린터를 돌리고 실행한 화면입니다.
# 고친 내용(아래 FIXED — 본문 4단계의 py 블록과 같습니다)을 그 파일에 써 넣은 뒤 명령을 부릅니다. 러너가 앞뒤로 되돌립니다.
import subprocess
import sys

RUFF = sys.prefix + "/bin/ruff"
# 화면에 나오는 차례대로 부르는 명령입니다. 실습 폴더에서 그대로 실행합니다.
COMMANDS = [['format', '--check', 'broken/untidy_report.py'], ['check', 'broken/untidy_report.py'], ['python', 'broken/untidy_report.py']]

FIXED = '''"""서식과 규칙을 일부러 어겨 둔 파일입니다."""


def summary(station, rains):
    added = 0.0
    days = 0
    for value in rains:
        added = added + value
        days = days + 1
    mean = added / days
    print("관측소", station, "합계", round(added, 1), "평균", round(mean, 2))
    print(
        "이 줄은 여든여덟 칸을 넘기도록 일부러 길게 적어 둔 안내 문장입니다. "
        "포매터가 문자열을 잘라 주지는 않습니다."
    )


summary("바람재", [0.1, 0.2, 0.3])
'''
with open("broken/untidy_report.py", "w", encoding="utf-8") as f:
    f.write(FIXED)

code = 0
for args in COMMANDS:
    if args[0] == "python":
        command = [sys.executable, *args[1:]]
    else:
        command = [RUFF, args[0], "--no-cache", *args[1:]]
    done = subprocess.run(command, capture_output=True, text=True)
    print(done.stdout, end="")
    print(done.stderr, end="")
    code = done.returncode
sys.exit(code)
