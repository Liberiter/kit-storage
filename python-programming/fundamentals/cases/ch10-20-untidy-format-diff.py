# 10.3절 «따라 하기» 2단계 — uv run ruff format --diff broken/untidy_report.py 의 화면입니다 (파일은 바뀌지 않습니다).
import subprocess
import sys

RUFF = sys.prefix + "/bin/ruff"
# 화면에 나오는 차례대로 부르는 명령입니다. 실습 폴더에서 그대로 실행합니다.
COMMANDS = [['format', '--diff', 'broken/untidy_report.py']]

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
