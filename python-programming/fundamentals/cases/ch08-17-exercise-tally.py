# exercise 1 — 지문의 work/ex1.py 와 해설의 출력입니다.
def tally(node):
    total = len(node["stations"])
    for child in node["children"]:
        total = total + tally(child)
    name = node["name"]
    print(f"{name}: {total}곳")
    return total


mountain = {
    "name": "산마루 권역",
    "children": [
        {"name": "윗재", "children": [], "stations": ["BJ", "SD"]},
        {"name": "너미골", "children": [], "stations": ["NM", "GS"]},
    ],
    "stations": [],
}
result = tally(mountain)
print("돌려받은 값:", result)
