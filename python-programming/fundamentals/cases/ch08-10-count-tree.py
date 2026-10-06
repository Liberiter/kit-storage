# 8.2절 «따라 하기» 2단계 — 재귀 함수 하나로 세 마디를 세는 work/count_tree.py 입니다.
def count_stations(node):
    total = len(node["stations"])
    for child in node["children"]:
        total = total + count_stations(child)
    return total


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
mountain = tree["children"][0]
print("바람재 관측망:", count_stations(tree))
print("산마루 권역:", count_stations(mountain))
print("윗재:", count_stations(mountain["children"][0]))
