# exercise 4 지문 — 고치기 전 work/ex4.py 의 화면입니다.
def name_of(code,names) :
    found=names.get(code)
    label=code.upper()
    if found==None :
        return code+" (목록에 없음)"
    else :
        return found
names={"BJ":"바람재","SD":"솔등","NM":"너미"}
shown=[]
for code in ["BJ","PT","NM"] :
    shown.append(name_of(code,names))
print(", ".join(shown))
