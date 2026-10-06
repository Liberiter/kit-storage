# problem 1 해설의 모범답안 work/log_check.py 입니다 (지문의 요구 화면과 같은 출력).
stations = {"BJ", "SD", "NM", "HG", "MR", "GS"}
lines = [
    "bj|2025-11-02| 0.0",
    "sd | 2025-11-02 | 결측",
    "NM|2025-11-02|0.0",
    "hg | 2025-11-02 | 0.0",
    "MR|2025-11-02| 0.0",
    "gs|2025-11-02|결측",
    " bj|2025-11-03|9.4",
    "sd|2025-11-03 | 8.8",
    "nm | 2025-11-03 | 결측",
    "hg|2025-11-03|7.2",
    "mr | 2025-11-03 | 0.0",
    "GS|2025-11-03|8.1",
    "pt|2025-11-03|6.6",
]
logged = set()
missing = set()
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    logged.add(code)
    if parts[2].strip() == "결측":
        missing.add(code)
unknown = ", ".join(sorted(logged - stations))
gaps = ", ".join(sorted(missing))
complete = ", ".join(sorted(stations - missing))
print(f"수첩의 줄 {len(lines)}개, 코드 {len(logged)}가지")
print(f"관측소 목록에 없는 코드: {unknown}")
print(f"결측이 적힌 코드: {gaps}")
print(f"결측 없이 적힌 관측소: {complete}")
