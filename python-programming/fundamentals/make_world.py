"""바람재 관측망의 자료 파일과 예제 파일을 만듭니다.

이 파일이 만드는 것은 세 곳입니다 — `data/`(관측 자료), `examples/`(예제
프로그램), `broken/`(일부러 고장 내 둔 파일). `./setup.sh`가 처음 한 번,
`./reset.sh`가 되돌릴 때마다 이 파일을 실행합니다.

같은 자리에서 몇 번을 실행해도 결과가 같습니다. 날짜·시각을 읽지 않고,
무작위 값은 고정된 씨앗에서 같은 차례로 뽑기 때문입니다. 여러분이 직접
실행하실 일은 없지만, 궁금하시면 읽어 보셔도 좋습니다.
"""

import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SEED = 20251101

# 관측소 — 코드, 이름, 고도(m), 종류, 종류별 항목
STATIONS = [
    ("BJ", "바람재", 612, "유인", {"observer": "한서린"}),
    ("SD", "솔등", 447, "자동", {"interval_min": 10}),
    ("NM", "너미", 158, "자동", {"interval_min": 10}),
    ("HG", "하곡", 93, "유인", {"observer": "문도윤"}),
    ("MR", "물레", 238, "자동", {"interval_min": 5}),
    ("GS", "갈숲", 355, "자동", {"interval_min": 10}),
]
CODES = sorted(code for code, *_ in STATIONS)

# 관측망 — 권역 아래 지역, 지역 아래 관측소. 마디마다 모양이 같습니다.
TREE = {
    "name": "바람재 관측망",
    "children": [
        {
            "name": "산마루 권역",
            "children": [
                {"name": "윗재", "children": [], "stations": ["BJ", "SD"]},
                {"name": "너미골", "children": [], "stations": ["NM", "GS"]},
            ],
            "stations": [],
        },
        {
            "name": "들녘 권역",
            "children": [
                {"name": "하곡", "children": [], "stations": ["HG"]},
                {"name": "물레", "children": [], "stations": ["MR"]},
            ],
            "stations": [],
        },
    ],
    "stations": [],
}

DAYS = 30
MONTH = "2025-11"
SKY_CLEAR = ["맑음", "구름많음", "흐림"]

# 비가 내린 날(1일을 0으로 센 번호)과 그날의 세기 배수
RAIN_DAYS = {3: 1.0, 4: 0.4, 12: 1.6, 13: 0.9, 21: 0.5, 22: 1.2, 27: 0.7}

# 위 규칙 위에 손으로 못 박은 값입니다. 코스의 예제가 이 값들에 기대고 있습니다.
# 하늘 상태는 여기서 정하지 않습니다 — 영하에 내린 비를 눈으로 적는 규칙은
# 아래 make_readings 한 곳에만 두어야 자료가 스스로와 어긋나지 않습니다.
OVERRIDES = {
    # 앞 두 날의 강수량을 더하면 셋째 날의 값과 같아 보이지만 그렇지 않습니다.
    ("BJ", 7): {"rain": 0.1},
    ("BJ", 8): {"rain": 0.2},
    ("BJ", 9): {"rain": 0.3},
    # 최저기온이 0도에서 갈리는 자리
    ("SD", 16): {"tmin": 0.0},
    ("NM", 16): {"tmin": 0.1},
    ("GS", 16): {"tmin": -0.1},
    # 영하에 눈이 내린 날 — 기온과 강수량을 함께 못 박습니다
    ("BJ", 21): {"tmin": -2.1, "rain": 4.5},
    ("SD", 21): {"tmin": -0.4, "rain": 3.1},
}


class Roll:
    """고정된 씨앗에서 같은 차례로 수를 뽑습니다."""

    def __init__(self, seed):
        self.state = seed & 0xFFFFFFFF

    def next_int(self):
        self.state = (1664525 * self.state + 1013904223) & 0xFFFFFFFF
        return self.state

    def between(self, low, high):
        """low 이상 high 이하의 값을 소수 둘째 자리까지 냅니다."""
        span = int(round((high - low) * 100)) + 1
        return low + (self.next_int() % span) / 100


def make_readings():
    """관측 기록 180건을 만듭니다 — 관측소 6곳 × 30일."""
    roll = Roll(SEED)
    elevation = {code: alt for code, _, alt, *_ in STATIONS}
    rows = []
    for day in range(DAYS):
        date = f"{MONTH}-{day + 1:02d}"
        for code in CODES:
            drop = elevation[code] * 0.006
            tmin = 3.6 - 0.16 * day - drop + roll.between(-2.5, 2.5)
            tmax = tmin + 6.5 + roll.between(-1.5, 3.0)
            rain = roll.between(0.5, 18.0) * RAIN_DAYS.get(day, 0.0)
            sky_pick = SKY_CLEAR[roll.next_int() % len(SKY_CLEAR)]
            row = {
                "station": code,
                "date": date,
                "tmin": round(tmin, 1),
                "tmax": round(tmax, 1),
                "rain": round(rain, 1),
            }
            row.update(OVERRIDES.get((code, day), {}))
            # 하늘 상태를 정하는 자리는 여기 한 곳입니다. 못 박은 값이 있어도
            # 기온과 강수량을 보고 다시 정하므로, 영하에 내린 비가 「비」로 남는
            # 일이 없습니다.
            if row["rain"] > 0:
                row["sky"] = "눈" if row["tmin"] <= 0 else "비"
            else:
                row["sky"] = sky_pick
            if row["tmax"] <= row["tmin"]:
                row["tmax"] = round(row["tmin"] + 1.0, 1)
            rows.append(row)
    return rows


def write_readings_txt(rows, path):
    lines = [
        "{station}|{date}|{tmin:.1f}|{tmax:.1f}|{rain:.1f}|{sky}".format(**row)
        for row in rows
    ]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_readings_json(rows, path):
    by_station = {code: [] for code in CODES}
    for row in rows:
        by_station[row["station"]].append(
            {
                "date": row["date"],
                "tmin": row["tmin"],
                "tmax": row["tmax"],
                "rain": row["rain"],
                "sky": row["sky"],
            }
        )
    data = {"month": MONTH, "stations": by_station}
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def write_stations_json(path):
    detail = {}
    for code, name, alt, kind, extra in STATIONS:
        item = {"name": name, "elevation": alt, "kind": kind}
        item.update(extra)
        detail[code] = item
    data = {"tree": TREE, "stations": detail}
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


# 현장 수첩을 그대로 옮겨 적은 기록입니다. 칸이 들쭉날쭉하고, 재지 못한 자리는
# 「결측」으로 적혀 있으며, 이제는 쓰지 않는 관측소(PT)도 남아 있습니다.
FIELD_LOG = """\
 bj | 2025-11-01 | 0.0
Sd|2025-11-01|0.0
nm | 2025-11-01|0.0
 HG|2025-11-01 | 0.0
mr|2025-11-01|0.0
gs | 2025-11-01 | 0.0
bj|2025-11-02| 0.0
sd | 2025-11-02 | 결측
NM|2025-11-02|0.0
hg | 2025-11-02 | 0.0
MR|2025-11-02| 0.0
gs|2025-11-02|결측
 bj|2025-11-03|9.4
sd|2025-11-03 | 8.8
nm | 2025-11-03 | 결측
hg|2025-11-03|7.2
mr | 2025-11-03 | 0.0
GS|2025-11-03|8.1
pt|2025-11-03|6.6
bj | 2025-11-04 | 3.5
sd|2025-11-04|3.9
nm|2025-11-04 | 3.1
hg | 2025-11-04 | 2.8
mr|2025-11-04|0.0
gs|2025-11-04| 3.3
PT | 2025-11-04 | 결측
"""

HELLO = '''\
"""바람재 관측망에 오신 것을 환영합니다."""

print("바람재 관측망")
print("관측소 6곳, 2025년 11월 기록 180건")
print("첫 프로그램을 실행하셨습니다.")
'''

NOTICE = '''\
"""불러들이면 맨 위의 문장이 한 번 실행되는 예제 모듈입니다."""

print("[알림 모듈] 준비되었습니다.")

HEAD = "바람재 관측망 알림"


def announce(text):
    """알림 한 줄을 정해진 모양으로 돌려줍니다."""
    return f"{HEAD}: {text}"
'''

WEATHER_NOTE = '''\
"""저녁 알림 문구를 만드는 모듈입니다. notice 모듈을 함께 씁니다."""

import notice


def evening_line():
    """저녁 알림 한 줄을 돌려줍니다."""
    return notice.announce("내일 아침 서리가 내리겠습니다")
'''

USE_NOTICE = '''\
"""notice 모듈을 두 곳에서 불러들여, 맨 위 문장이 언제 실행되는지 봅니다."""

import notice
import weather_note

print(notice.announce("오늘 낮 기온이 크게 떨어집니다"))
print(weather_note.evening_line())
'''

RAINFALL = '''\
"""강수량 목록을 다루는 작은 함수들입니다."""


def total(rains):
    """강수량을 모두 더해 소수 한 자리로 돌려줍니다."""
    added = 0.0
    for value in rains:
        added = added + value
    return round(added, 1)


def rainy_days(rains):
    """0보다 큰 값이 몇 번인지 셉니다."""
    count = 0
    for value in rains:
        if value > 0:
            count = count + 1
    return count


def heaviest(rains):
    """가장 큰 값을 돌려줍니다. 목록이 비어 있으면 0.0입니다."""
    if not rains:
        return 0.0
    top = rains[0]
    for value in rains:
        if value > top:
            top = value
    return top
'''

RAINFALL_FLAWED = '''\
"""강수량 목록을 다루는 작은 함수들입니다 — 한 곳에 결함을 심어 두었습니다."""


def total(rains):
    """강수량을 모두 더해 소수 한 자리로 돌려줍니다."""
    added = 0.0
    for value in rains:
        added = added + value
    return round(added, 1)


def rainy_days(rains):
    """0보다 큰 값이 몇 번인지 셉니다."""
    count = 0
    for value in rains:
        if value >= 0:
            count = count + 1
    return count


def heaviest(rains):
    """가장 큰 값을 돌려줍니다. 목록이 비어 있으면 0.0입니다."""
    if not rains:
        return 0.0
    top = rains[0]
    for value in rains:
        if value > top:
            top = value
    return top
'''

SYNTAX_ERROR = '''\
"""일부러 고장 내 둔 파일입니다. 실행하면 문법 오류가 납니다."""

station = "바람재"
print("관측소:", station
print("고도: 612m")
'''

LONG_SENTENCE = (
    "이 줄은 여든여덟 칸을 넘기도록 일부러 길게 적어 둔 안내 문장입니다. "
    "포매터가 문자열을 잘라 주지는 않습니다."
)

UNTIDY = (
    '"""서식과 규칙을 일부러 어겨 둔 파일입니다."""\n'
    "def summary(station,rains) :\n"
    "    added=0.0\n"
    "    days = 0\n"
    '    unused = "여기 있지만 아무도 쓰지 않습니다"\n'
    "    for value in rains :\n"
    "        added=added+value\n"
    "        days = days+1\n"
    "    mean = added/days\n"
    '    print( "관측소", station, "합계", round(added,1), "평균", round(mean,2) )\n'
    f'    print("{LONG_SENTENCE}")\n'
    'summary("바람재",[0.1,0.2,0.3])\n'
)


def write_report(rows, path):
    """읽기·고르기·계산·보고가 한 파일에 섞여 있는 예제를 만듭니다."""
    picked = [row for row in rows if row["station"] == "BJ"][:10]
    body = [
        '"""바람재 관측소의 열흘치 기록을 읽어 한 줄로 보고합니다."""',
        "",
        "records = [",
    ]
    for row in picked:
        line = "{station}|{date}|{tmin:.1f}|{tmax:.1f}|{rain:.1f}|{sky}".format(**row)
        body.append(f'    "{line}",')
    body += [
        "]",
        "",
        "# 1단계 — 읽기: 줄을 칸으로 나눕니다.",
        "split_rows = []",
        "for line in records:",
        '    split_rows.append(line.split("|"))',
        "",
        "# 2단계 — 고르기: 비가 온 날만 남깁니다.",
        "rainy = []",
        "for cells in split_rows:",
        "    if float(cells[4]) > 0:",
        "        rainy.append(cells)",
        "",
        "# 3단계 — 계산: 강수량을 더합니다.",
        "added = 0.0",
        "for cells in rainy:",
        "    added = added + float(cells[4])",
        "",
        "# 4단계 — 보고: 한 줄로 알립니다.",
        'print("관측소:", split_rows[0][0])',
        'print("읽은 날수:", len(split_rows))',
        'print("비 온 날수:", len(rainy))',
        'print("강수량 합계:", round(added, 1))',
        "",
    ]
    path.write_text("\n".join(body), encoding="utf-8")


def main():
    rows = make_readings()
    data = HERE / "data"
    examples = HERE / "examples"
    broken = HERE / "broken"
    for folder in (data, examples, broken):
        folder.mkdir(exist_ok=True)

    write_readings_txt(rows, data / "readings.txt")
    write_readings_json(rows, data / "readings.json")
    write_stations_json(data / "stations.json")
    (data / "field_log.txt").write_text(FIELD_LOG, encoding="utf-8")

    (examples / "hello_baramjae.py").write_text(HELLO, encoding="utf-8")
    (examples / "notice.py").write_text(NOTICE, encoding="utf-8")
    (examples / "weather_note.py").write_text(WEATHER_NOTE, encoding="utf-8")
    (examples / "use_notice.py").write_text(USE_NOTICE, encoding="utf-8")
    (examples / "rainfall.py").write_text(RAINFALL, encoding="utf-8")
    write_report(rows, examples / "report.py")

    (broken / "syntax_error.py").write_text(SYNTAX_ERROR, encoding="utf-8")
    (broken / "untidy_report.py").write_text(UNTIDY, encoding="utf-8")
    (broken / "rainfall.py").write_text(RAINFALL_FLAWED, encoding="utf-8")

    print(f"관측 기록 {len(rows)}건")


if __name__ == "__main__":
    main()
