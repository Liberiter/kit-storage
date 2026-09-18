# 자기를 부르는 함수로 중첩 구조를 훑는 유형입니다.
# 이 케이스가 받치는 것: 관측망 나무(권역 → 지역 → 관측소)가 제 모양인지.
import json
from pathlib import Path

data = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))


def count_stations(node):
    """이 마디 아래에 달린 관측소가 모두 몇 곳인지 셉니다."""
    total = len(node["stations"])
    for child in node["children"]:
        total = total + count_stations(child)
    return total


def show(node, depth):
    print("  " * depth + f"{node['name']}: {count_stations(node)}곳")
    for child in node["children"]:
        show(child, depth + 1)


show(data["tree"], 0)
print("관측소 종류:", sorted({s["kind"] for s in data["stations"].values()}))
