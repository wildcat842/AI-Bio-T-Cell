# Experiment Template

새 실험을 시작할 때:

```bash
cp -r experiments/_template experiments/YYYYMMDD_topic1_my-run
cd experiments/YYYYMMDD_topic1_my-run
# config.yaml 수정 → 실행
```

각 실험 폴더는 다음을 포함합니다.

```
experiments/<name>/
├── config.yaml          # 모든 하이퍼파라미터·입력 (재현 가능성)
├── README.md            # 가설·결과 요약
├── runs/                # 학습 로그·체크포인트 (.gitignored)
├── outputs/             # 그림·테이블 산출
└── logs/                # stdout/stderr 사본
```

## 결과 요약 (작성 후 채울 것)
- 가설:
- 결과:
- 결론:
- 다음 실험:
