# 8.2절 «따라 하기» 1단계 work/count_mountain.py 입니다 (8.2절 «예측해 보기»의 코드와 같습니다).
def count_stations(node):
    total = len(node["stations"])
    for child in node["children"]:
        total = total + count_stations(child)
    return total


mountain = {
    "name": "산마루 권역",
    "children": [
        {"name": "윗재", "children": [], "stations": ["BJ", "SD"]},
        {"name": "너미골", "children": [], "stations": ["NM", "GS"]},
    ],
    "stations": [],
}
print(count_stations(mountain["children"][0]))
print(count_stations(mountain))
