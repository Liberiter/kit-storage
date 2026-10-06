# 복습 exercise 2 해설 — 키를 바로 적은 work/review2.py 입니다.
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
print("바람재 관측망:", count_stations(tree))
