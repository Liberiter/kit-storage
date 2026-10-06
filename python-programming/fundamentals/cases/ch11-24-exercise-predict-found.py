# exercise 1 지문(코드)과 해설(출력) work/ex1.py 입니다.
names = {"BJ": "바람재", "SD": "솔등"}
found = []
for code in ["SD", "PT", "BJ"]:
    try:
        found.append(names[code])
    except KeyError:
        print(code, "없음")
print(found)
print(len(found))
