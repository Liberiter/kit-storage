# 6.1절 «따라 하기» 2단계 — 항목을 더하고 바꾸는 work/names_grow.py 입니다.
names = {}
names["BJ"] = "바람재"
names["SD"] = "솔동"
print(names, len(names))
names["SD"] = "솔등"
print(names, len(names))
for code in names:
    print(code, names[code])
