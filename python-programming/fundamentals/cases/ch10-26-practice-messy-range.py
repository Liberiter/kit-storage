# 10.3절 practice 1 풀이 — 모양이 흐트러진 work/messy_range.py 에 포매터를 돌리고, 린터를 돌리고, 실행한 화면입니다.
# 임시 폴더의 work/ 에 지문의 내용을 써서 부릅니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
NAME = 'work/messy_range.py'
SOURCE = """def daily_range(low,high) :
    return high-low
bj_low=[-1.5,1.6,0.3]
bj_high=[7.8,10.9,8.4]
print( [round(daily_range(low,high),1) for low,high in zip(bj_low,bj_high)] )
"""
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 그 파일을 실행하는 것이고,
# 나머지는 ruff 의 하위 명령입니다. 실습 폴더의 설정 파일을 그대로 씁니다.
COMMANDS = [['format'], ['check'], ['python']]

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    with open(os.path.join(tmp, NAME), "w", encoding="utf-8") as f:
        f.write(SOURCE)
    code = 0
    for args in COMMANDS:
        if args[0] == "python":
            command = [sys.executable, NAME]
        else:
            config = ["--config", os.path.join(KIT, "pyproject.toml"), "--no-cache"]
            command = [RUFF, args[0], *config, *args[1:], NAME]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        print(done.stdout, end="")
        print(done.stderr, end="")
        code = done.returncode
sys.exit(code)
