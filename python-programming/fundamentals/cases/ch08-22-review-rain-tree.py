# 복습 exercise 1 해설의 모범답안 work/review1.py 입니다 (지문의 요구 화면과 같은 출력).
def rain_total(node, totals):
    total = 0.0
    for code in node["stations"]:
        total = total + totals[code]
    for child in node["children"]:
        total = total + rain_total(child, totals)
    return total


def show_rain(node, totals, depth=0):
    indent = "  " * depth
    name = node["name"]
    print(f"{indent}{name}: {rain_total(node, totals):.1f}mm")
    for child in node["children"]:
        show_rain(child, totals, depth=depth + 1)


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
totals = {"BJ": 67.1, "SD": 59.4, "NM": 56.2, "HG": 58.5, "MR": 61.0, "GS": 48.6}
show_rain(tree, totals)
