# 9.3절 «따라 하기» 2단계 — get() 이 돌려준 None 을 is 로 확인하는 work/get_name.py 입니다.
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
print(names.get("SD"), names.get("PT"))
for code in ["SD", "PT"]:
    name = names.get(code)
    if name is None:
        print(f"{code}: 관측소 목록에 없습니다")
    else:
        print(f"{code}: {name}")
print(names.get("PT", "모름"))
