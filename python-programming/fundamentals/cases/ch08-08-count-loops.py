# 8.2절 «문제 상황» — 관측망 나무를 반복문으로 세는 work/count_loops.py 입니다.
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
whole = 0
for region in tree["children"]:
    for area in region["children"]:
        whole = whole + len(area["stations"])
print("바람재 관측망:", whole)
mountain = tree["children"][0]
part = 0
for area in mountain["children"]:
    part = part + len(area["stations"])
print("산마루 권역:", part)
print("윗재:", len(mountain["children"][0]["stations"]))
