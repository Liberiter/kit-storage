# kit-storage

learning-loop 학습 자료의 **실습 kit** 배포 저장소입니다. 각 코스의 예제·문제는
여기 담긴 world(공유 예제 데이터)와 구축·검증 스크립트 위에서 돕니다.

## 구조

learning-loop 저장소의 `tracks/<트랙>/courses/<코스>/kit/`와 같은 배치입니다.

```
kit-storage/
└─ sql-programming/          ← 트랙(과목)
   └─ fundamentals/          ← 코스 — 챕터 본문이 말하는 "kit 디렉토리"
      ├─ README.md           ← 사용법·두 경로(Docker/네이티브)·실패 안내
      ├─ setup.sh            ← 환경 구축 + world 적재 + 검증
      ├─ check_env.sh        ← entry check
      ├─ reset.sh            ← world 초기화
      ├─ verify.sh           ← 예제·문제 자동 검증
      └─ cases/              ← 검증 케이스
```

새 코스(`sql-programming/intermediate`)나 새 트랙(`python-programming/fundamentals`)이
생기면 같은 규칙으로 디렉토리가 늘어납니다.

## 받기

```bash
git clone https://github.com/Liberiter/kit-storage.git
cd kit-storage/sql-programming/fundamentals
./setup.sh
```

스크립트는 bash입니다. Windows에서는 WSL2 셸(Docker Desktop의 WSL2 백엔드가 쓰는
배포판) 안에서 clone하고 실행하세요.

## 정본

이 저장소는 배포용 사본입니다. 정본은 learning-loop 저장소의 kit 디렉토리이고,
학습 자료 본문은 https://liberiter.github.io 에 연재됩니다.
