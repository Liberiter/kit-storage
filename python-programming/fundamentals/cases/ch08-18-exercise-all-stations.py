# exercise 2 해설의 모범답안 work/ex2.py 입니다 (지문의 요구 화면과 같은 출력).
def all_stations(node):
    found = []
    for code in node["stations"]:
        found.append(code)
    for child in node["children"]:
        for code in all_stations(child):
            found.append(code)
    return found


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
print(all_stations(tree))
print(all_stations(tree["children"][1]))
print(all_stations(tree["children"][0]["children"][1]))
