# problem 2 해설의 모범답안 work/highest.py 입니다 (지문의 요구 화면과 같은 출력).
def highest(node, elevations):
    best = ""
    for code in node["stations"]:
        if best == "" or elevations[code] > elevations[best]:
            best = code
    for child in node["children"]:
        found = highest(child, elevations)
        if found != "" and (best == "" or elevations[found] > elevations[best]):
            best = found
    return best


def show_highest(node, elevations, names, depth=0):
    indent = "  " * depth
    name = node["name"]
    code = highest(node, elevations)
    print(f"{indent}{name}: {names[code]} {elevations[code]}m")
    for child in node["children"]:
        show_highest(child, elevations, names, depth + 1)


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
elevations = {"BJ": 612, "SD": 447, "NM": 158, "HG": 93, "MR": 238, "GS": 355}
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
show_highest(tree, elevations, names)
