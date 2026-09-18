# 다른 파일을 실행한 화면을 담는 유형입니다 — 오류 화면을 고정할 때 씁니다.
# 이 케이스가 받치는 것: 일부러 고장 내 둔 파일이 문법 오류 화면을 내는지.
import subprocess
import sys

done = subprocess.run(
    [sys.executable, "broken/syntax_error.py"],
    capture_output=True,
    text=True,
)
print(done.stdout, end="")
print(done.stderr, end="")
sys.exit(done.returncode)
