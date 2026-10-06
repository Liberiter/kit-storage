# 8.2절 «왜 그럴까요» — 자기 호출에 같은 마디를 넘기는 work/same_node.py 의 화면입니다 (RecursionError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/same_node.py"
SOURCE = """def count_stations(node):
    total = len(node["stations"])
    for child in node["children"]:
        total = total + count_stations(node)
    return total


mountain = {
    "name": "산마루 권역",
    "children": [
        {"name": "윗재", "children": [], "stations": ["BJ", "SD"]},
        {"name": "너미골", "children": [], "stations": ["NM", "GS"]},
    ],
    "stations": [],
}
print(count_stations(mountain))
"""

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    with open(os.path.join(tmp, NAME), "w", encoding="utf-8") as f:
        f.write(SOURCE)
    done = subprocess.run(
        [sys.executable, NAME], cwd=tmp, capture_output=True, text=True
    )
    screen = done.stdout + done.stderr
    for root in (os.path.realpath(tmp), tmp):
        screen = screen.replace(root + os.sep, "")
print(screen, end="")
sys.exit(done.returncode)
