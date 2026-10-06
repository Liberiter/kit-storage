# 5.3절 «따라 하기» 3단계 — work/split_fields.py 입니다.
line = "bj | 2025-11-04 | 3.5"
parts = line.split("|")
print(parts)
print(len(parts))
code = parts[0].strip().upper()
date = parts[1].strip()
amount = float(parts[2].strip())
print(f"{code} {date} {amount}mm")
