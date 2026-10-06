# 9.3절 «왜 그럴까요» — None 은 하나뿐인 객체이고 빈 리스트는 만들 때마다 새 객체임을 보이는 work/none_once.py 입니다.
names = {"BJ": "바람재", "SD": "솔등"}
missing = names.get("PT")
also_missing = names.get("XX")
print(missing is also_missing, missing is None)
empty = []
also_empty = []
print(empty == also_empty, empty is also_empty)
empty.append(0.0)
print(empty, also_empty)
