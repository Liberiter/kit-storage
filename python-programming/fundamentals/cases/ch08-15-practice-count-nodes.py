# 8.2절 practice 1 풀이 work/count_nodes.py 입니다 (지문의 요구 화면과 같은 출력).
def count_nodes(node):
    total = 1
    for child in node["children"]:
        total = total + count_nodes(child)
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
print(f"바람재 관측망: 마디 {count_nodes(tree)}개")
print(f"산마루 권역: 마디 {count_nodes(mountain)}개")
area = mountain["children"][0]
print(f"윗재: 마디 {count_nodes(area)}개")
