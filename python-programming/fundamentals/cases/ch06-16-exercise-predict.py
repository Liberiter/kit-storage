# exercise 1 — 지문의 work/ex1.py 이고, 기대 출력은 해설의 네 줄입니다.
rain = {"BJ": 13.6, "SD": 8.5}
rain["NM"] = 8.5
rain["BJ"] = rain["BJ"] + 3.8
print(len(rain), rain["BJ"])
print("HG" in rain, "SD" not in rain)
early = set("흐맑흐비비구맑눈눈눈")
late = set("구눈눈흐구구구눈구구")
print(sorted(early - late), sorted(late - early))
print(len(early & late), len(early | late))
