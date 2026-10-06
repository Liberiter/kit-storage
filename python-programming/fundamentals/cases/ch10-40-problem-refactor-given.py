# problem 2 지문 — 고치기 전 work/ranges.py 의 화면입니다.
def r(l2,k) :
    o=[]
    for x in l2 :
        c=x.split("|")
        if c[0]==k :
            o.append(round(float(c[3])-float(c[2]),1))
    return o
z=[
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "NM|2025-11-01|2.6|7.6|0.0|구름많음",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "NM|2025-11-02|1.6|10.8|0.0|흐림",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "NM|2025-11-03|2.4|7.4|0.0|흐림",
]
for k in ["BJ","NM"] :
    o2=r(z,k)
    print(k,o2,max(o2))
