# exercise 4 해설의 모범답안 work/ex4.py 입니다 (지문의 요구 화면과 같은 출력).
def area_of(node, code):
    if code in node["stations"]:
        return node["name"]
    for child in node["children"]:
        found = area_of(child, code)
        if found != "":
            return found
    return ""


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
for code in ["NM", "MR", "PT"]:
    area = area_of(tree, code)
    if area != "":
        print(f"{code}: {area}")
    else:
        print(f"{code}: 관측망에 없습니다")
