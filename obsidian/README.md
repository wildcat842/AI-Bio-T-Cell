# Obsidian Vault - AI-Bio-T-Cell 공동 연구 노트

이 폴더는 AI-Bio-T-Cell 프로젝트의 연구 진행 상황을 다른 학자들과 공유하기 위한 **Obsidian vault**입니다.

## 사용 방법

1. [Obsidian](https://obsidian.md) 설치 (무료, Win/Mac/Linux/iOS/Android)
2. Obsidian 실행 → **"Open folder as vault"** → 본 폴더(`obsidian/`)를 선택
3. 시작점: [[00_Index/Home]]

## 폴더 구조 (PARA + Zettelkasten 혼합)

| 폴더 | 용도 |
| --- | --- |
| `00_Index/` | 진입점·MOC(Map of Contents). 모든 작업의 첫 페이지 |
| `10_Concepts/` | 배경 개념 (AI Virtual Cells, T-Cell Exhaustion, ReapTEC 등) |
| `20_Topics/` | 4개 연구 토픽별 작업 노트 (살아있는 문서) |
| `30_Daily/` | 일일 일지 (Daily Notes). 형식: `YYYY-MM-DD.md` |
| `40_Meetings/` | 회의록 (외부 RIKEN 협업 미팅 포함) |
| `50_Literature/` | 논문 노트 (한 논문 = 한 파일, [author][year][slug] 형식) |
| `60_Methods/` | 방법론 노트 (Flow Matching, UDSB, GNN 등) |
| `70_Decisions/` | ADR (Architecture/Approach Decision Records). 한 결정 = 한 파일 |
| `_templates/` | 노트 템플릿 (Templates 플러그인이 참조) |
| `_attachments/` | 이미지·첨부 파일 |

## 노트 작성 규칙

- **링크는 wikilink** 사용: `[[20_Topics/Topic1_Waddington_Attractor]]`
- **태그**: `#topic/1`, `#method/flow-matching`, `#data/reaptec`, `#meeting/riken`, `#decision`
- **YAML frontmatter** 필수: 생성일, 수정일, 태그, 상태
- 새 일지는 `_templates/Daily.md` 복사로 시작
- 새 논문 노트는 `_templates/Literature.md` 복사로 시작

## 권장 Obsidian 플러그인 (커뮤니티)

- **Templates** (core) - 템플릿 자동 삽입
- **Daily notes** (core) - 일지
- **Dataview** - 노트를 데이터처럼 쿼리
- **Excalidraw** - 다이어그램
- **Citations** - BibTeX/Zotero 연동
- **Git** - vault 자체 git 동기화 (선택)

## 공유·동기화 옵션

- **Git 동기화**: 본 vault는 프로젝트 git 레포의 일부이므로 자동 동기화 (단, `workspace.json` 등 일부 파일은 .gitignore)
- **Obsidian Sync** (유료): 실시간 협업 시
- **GitHub Pages**: `obsidian-publish-pages-rs` 등으로 정적 사이트 발행 가능

## 첫 진입 추천 경로

[[00_Index/Home]] → [[20_Topics/Topic4_Enhancer_Regulatory_Network]] → [[50_Literature/Oguchi2024_ReapTEC]]
