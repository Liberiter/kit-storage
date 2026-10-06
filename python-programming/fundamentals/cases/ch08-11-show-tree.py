# 8.2절 «따라 하기» 3단계 — 나무를 들여써 내는 work/show_tree.py 입니다.
def count_stations(node):
    total = len(node["stations"])
    for child in node["children"]:
        total = total + count_stations(child)
    return total


def show(node, depth):
    indent = "  " * depth
    name = node["name"]
    print(f"{indent}{name}: {count_stations(node)}곳")
    for child in node["children"]:
        show(child, depth + 1)


tree = {
    "name": "바람재 관측망",
    "children": [
        {
            "name": "산마루 권역",
            "children": [
                {"name": "윗재", "children": [], "stations": ["BJ", "SD"]},
                {"name": "너미골", "children": [], "stations": ["NM", "GS"]},
            ],
            "stations": [],
        },
        {
            "name": "들녘 권역",
            "children": [
                {"name": "하곡", "children": [], "stations": ["HG"]},
                {"name": "물레", "children": [], "stations": ["MR"]},
            ],
            "stations": [],
        },
    ],
    "stations": [],
}
show(tree, 0)
