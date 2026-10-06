# 복습 exercise 2 해설의 모범답안 work/review2.py 입니다 (지문의 요구 화면과 같은 출력).
def codes_in(node):
    found = set(node["stations"])
    for child in node["children"]:
        found = found | codes_in(child)
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
lines = [
    " bj|2025-11-03|9.4",
    "sd|2025-11-03 | 8.8",
    "nm | 2025-11-03 | 결측",
    "hg|2025-11-03|7.2",
    "mr | 2025-11-03 | 0.0",
    "GS|2025-11-03|8.1",
    "pt|2025-11-03|6.6",
]
logged = set()
for line in lines:
    logged.add(line.split("|")[0].strip().upper())
unknown = ", ".join(sorted(logged - codes_in(tree)))
print(f"관측망에 없는 코드: {unknown}")
for region in tree["children"]:
    name = region["name"]
    joined = ", ".join(sorted(codes_in(region)))
    print(f"{name}: {joined}")
