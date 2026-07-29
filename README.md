# claude-skills

스폰지클럽 멤버들을 위한 Claude Code 스킬 모음

인스타그램에서 공유된 "바이브코더 스킬 8종" 중 리스크 검증(실존 여부·관리 상태·설치 스크립트·보안 이슈)을 거쳐 통과한 3종을 선별 수록했습니다. (검증일: 2026-07-22)

## 수록 스킬

| 경로 | 출처 | 라이선스 | 용도 |
|---|---|---|---|
| `skills/im-not-ai/` | [epoko77-ai/im-not-ai](https://github.com/epoko77-ai/im-not-ai) (v2.2, ★3.9k) | MIT | 한글 AI 티 제거 — AI가 쓴 티 나는 번역체·상투 표현을 사람 문장으로 교정 |
| `skills/frontend-slides/` | [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) (v2.1, ★26k) | MIT | 개요·PPTX → 의존성 없는 단일 HTML 웹 발표자료 생성 |
| `design-md/` | [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (★104k) | MIT | 유명 브랜드 디자인 시스템 레퍼런스 (12개 브랜드 큐레이션) |

## 설치 방법

### im-not-ai (한글 AI 티 제거)

```bash
cd skills/im-not-ai && ./install.sh
```

`~/.claude/skills/`에 humanize-korean·humanize·humanize-redo 스킬과 전용 에이전트들이 설치됩니다. 설치 스크립트는 로컬 복사/심링크만 수행하며 외부 다운로드·API 키·훅 등록이 없습니다(직접 검수 완료). 이후 Claude Code에서 `/humanize-korean`으로 사용.

### frontend-slides (웹 발표자료)

```bash
cp -R skills/frontend-slides ~/.claude/skills/frontend-slides
```

"발표자료 만들어줘"라고 하면 자동 트리거됩니다. PPTX 변환은 `pip install python-pptx` 필요.

> ⚠️ 업스트림의 `deploy.sh`(Vercel 공개 배포)·`export-pdf.sh`(PDF 내보내기)는 미해결 보안 이슈(경로 조작)로 **제외**했습니다. 상세: [`skills/frontend-slides/scripts/SECURITY-NOTE.md`](skills/frontend-slides/scripts/SECURITY-NOTE.md)

### design-md (브랜드 디자인 레퍼런스)

원하는 브랜드의 `DESIGN.md` 한 개를 작업 중인 프로젝트 루트에 복사한 뒤 "이 DESIGN.md 스타일로 만들어줘"라고 지시합니다. 실행 코드가 전혀 없는 순수 마크다운입니다.

```bash
cp design-md/nike/DESIGN.md ./DESIGN.md
```

수록 브랜드: nike · airbnb · apple · pinterest · shopify · spotify · starbucks · stripe · notion · linear.app · figma · vercel
(전체 73개는 업스트림 참고. 한국 브랜드는 미포함 — "토스처럼"은 이 저장소로는 불가)

> ⚠️ 브랜드 디자인 레퍼런스는 커뮤니티가 공개 CSS에서 추출한 비공식 자료입니다. 특정 브랜드의 룩을 상업 결과물에 통째로 복제하면 트레이드 드레스 이슈가 될 수 있으니 참고용으로만 사용하세요.

### marketingskills (마케팅 스킬 49종) — 외부 설치형

저장소에 수록하지 않고 업스트림에서 바로 설치합니다. 설치 위치·보안 검증·장단점은
[`docs/marketingskills-review.md`](docs/marketingskills-review.md)를 참고하세요.

**권장 12종** (49개 전체는 오발동·컨텍스트 부담이 커서 선별했습니다):

```bash
npx skills add coreyhaines31/marketingskills --skill \
  product-marketing customer-research marketing-psychology \
  cro offers copywriting social ads ad-creative \
  analytics ab-testing marketing-plan
```

전체가 필요하면 `npx skills add coreyhaines31/marketingskills` (49개).
선별 기준과 제외 사유는 리뷰 문서에 정리돼 있습니다.

> 💡 **`product-marketing`을 제일 먼저 한 번 돌리세요.** `.agents/product-marketing.md`가 생기면
> 나머지 스킬이 매번 이걸 읽어서 제품·ICP를 다시 안 물어봅니다. 진단 품질이 여기서 갈립니다.

Claude Code 안에서는 `/plugin marketplace add coreyhaines31/marketingskills` → `/plugin install marketing-skills`도 가능합니다.

> ⚠️ 에이전트 세션 안에서 `npx skills add`를 돌리면 `.agents/skills/`에만 깔려 Claude Code가 못 읽는 경우가 있습니다.
> `.claude/skills/`에 심링크가 걸렸는지 확인하고, 없으면 `--agent claude-code`를 붙여 재설치하세요.
> 스킬 본문이 전부 영어·B2B SaaS 기준이라 한국어 카피 작업에는 `im-not-ai`와 병용을 권장합니다.

## 검증 후 보류/제외한 스킬

| 스킬 | 사유 |
|---|---|
| oh-my-design | npx 설치기가 상시 훅(SessionStart 등)을 등록, 1인 관리 저장소 — 훅 검수 후 개별 판단 |
| claude-seo | bash 설치기 + Python + 헤드리스 크롬 실행 툴체인 — SEO 본격화 시 재검토 |
| n8n-skills | 신뢰도는 높으나 n8n-mcp 서버 + n8n 인스턴스/API 키 전제 |
| OpenMontage | 스킬이 아닌 풀 영상 제작 앱(Python/FFmpeg/Remotion), 최근 커맨드 인젝션 패치 이력 |
| chromux | ★38개·5주차 신생 프로젝트, 라이브 모드가 로그인된 실제 브라우저를 무인증 로컬 브리지로 노출 |

## 라이선스

수록된 각 스킬의 원 라이선스(MIT)와 저작권 고지는 각 디렉터리의 `LICENSE` 파일을 따릅니다.
