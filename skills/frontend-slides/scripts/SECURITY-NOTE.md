# 제외된 스크립트 안내

업스트림(zarazhangrui/frontend-slides)의 `scripts/deploy.sh`(Vercel 배포)와
`scripts/export-pdf.sh`(PDF 내보내기)는 이 저장소에 **포함하지 않았습니다.**

사유:
- 2026-07-02에 업스트림에 열린 미해결 보안 이슈(경로 조작 및 네트워크 노출)가
  두 스크립트를 대상으로 함
- `deploy.sh`는 슬라이드를 공개 Vercel URL로 배포하므로 클라이언트 제안서 등
  비공개 자료 노출 위험이 있음
- `export-pdf.sh`는 최초 실행 시 Playwright가 Chromium 바이너리를 다운로드함

슬라이드 생성·PPTX 변환(`extract-pptx.py`)은 이 스크립트들 없이 정상 동작합니다.
공유가 필요하면 생성된 단일 HTML 파일을 직접 전달하세요.

추후 이슈가 해결되면 업스트림에서 다시 받아올 수 있습니다:
https://github.com/zarazhangrui/frontend-slides/tree/main/scripts
