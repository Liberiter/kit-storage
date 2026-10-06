# runner: reset
# 10.3절 «따라 하기» 3단계 — uv run ruff format broken/untidy_report.py 뒤 uv run ruff check broken/untidy_report.py 의 화면입니다.
# 포매터가 실습 자료를 고쳐 쓰므로 러너가 앞뒤로 되돌립니다.
import subprocess
import sys

RUFF = sys.prefix + "/bin/ruff"
# 화면에 나오는 차례대로 부르는 명령입니다. 실습 폴더에서 그대로 실행합니다.
COMMANDS = [['format', 'broken/untidy_report.py'], ['check', 'broken/untidy_report.py']]

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
