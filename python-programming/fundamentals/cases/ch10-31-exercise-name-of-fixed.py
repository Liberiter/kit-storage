# exercise 4 해설 — 고친 work/ex4.py 에 포매터 검사·린터를 돌리고 실행한 화면입니다.
# 임시 폴더의 work/ 에 같은 내용을 써서 부릅니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
NAME = 'work/ex4.py'
SOURCE = """def name_of(code, names):
    found = names.get(code)
    if found is None:
        return code + " (목록에 없음)"
    else:
        return found


names = {"BJ": "바람재", "SD": "솔등", "NM": "너미"}
shown = [name_of(code, names) for code in ["BJ", "PT", "NM"]]
print(", ".join(shown))
"""
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 그 파일을 실행하는 것이고,
# 나머지는 ruff 의 하위 명령입니다. 실습 폴더의 설정 파일을 그대로 씁니다.
COMMANDS = [['format', '--check'], ['check'], ['python']]

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
