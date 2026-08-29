# 키즈튜터 — 유아·초등 저학년 화상과외 사이트 (이어서 작업용)

## 개요
- 5세~초3 대상 **1:1 화상과외** 홍보 사이트. 정적 HTML/CSS/JS, GitHub Pages 배포 (gwaoe-page / wawa-renewal 과 같은 형식)
- **브랜드:** 키즈튜터 (티칭코칭 perfectedu.co.kr 의 유아·초등 저학년 서비스. 사이트 안에서 티칭코칭은 모회사로만 언급)
- **도메인:** https://kidstutor.co.kr (가비아 구매, `CNAME` 파일 있음). GitHub Pages 브랜치: **main**
- **상담 전화:** 010-6832-1994 (티칭코칭과 동일)

## 배포 방법
```
git add .
git commit -m "메시지"
git push
```
→ GitHub Pages 설정 후 1~2분 뒤 반영. (저장소·Pages 설정은 아래 "처음 배포" 참고)

## 파일 구조
- `index.html` — 홈 (히어로/연령별 탭/프로그램 6종/수업 흐름/걱정 해결/선생님 미리보기/후기/FAQ/무료 체험 신청 폼)
- `teachers.html` — 선생님 찾기 (검색 + 필터: 대상(유아·아동 코칭 경력/초1부터)/과목/성별/수업형태, 24명씩 페이지네이션). `?s=영어`, `?kid=1` 로 필터 진입 가능
- `teacher-{id}.html` — 선생님 개별 페이지 (**gen.ps1 로 자동 생성**, 손으로 고치지 말 것)
- `process.html` — 수업방식 (준비물/수업 길이표/진행 흐름/관리/상담 폼)
- `teachers-data.js` — `window.TEACHERS=[{i,n,g,c,s,gr,r,sd,k}]` (gen.ps1 생성. k=1 이면 유아·아동 코치)
- `teachers-search.js` — 검색 색인 `window.TSEARCH` (gen.ps1 생성, defer 로드)
- `style.css` — gwaoe-page/style.css 를 복사해 토큰만 키즈 팔레트로 바꾸고, 끝에 "키즈 전용 추가" 블록을 붙인 것
  - ⚠️ 수정 시 전 페이지의 `style.css?v=` 숫자 올리기 (현재 v1)
- `script.js` — gwaoe-page 와 동일 (reveal, paginate)
- `form.js` — 신청 폼 → 구글 시트. 과외·픽포스·데일리카네기와 **같은 공용 Apps Script 웹앱** → "웹 문의" 시트의 **"키즈튜터" 탭**(`sheet=키즈튜터` 전송, 구분 `키즈튜터-무료체험신청` 등). 참고 사본 `google-apps-script.gs` (허용 탭 목록 버전이면 `"키즈튜터": true` 추가 필요)
- `gen.ps1` — 선생님 데이터/페이지/sitemap 생성기 · `make-images.ps1` — og-image.png / apple-touch-icon.png 생성기
- `sitemap.xml` (gen.ps1 생성) / `robots.txt` / `favicon.svg`

## 디자인
- 팔레트: 주황 `--brand:#ff7a1f` / 살구 `--brand-2:#ffa94d` / 민트 `--accent:#1fb59b` / 노랑 `--sun:#ffd166` / 잉크 `#1e2a3f` / 바탕 `#fff7ee`
- 서체: 제목 **Jua**(Google Fonts) + 본문 Pretendard. 각 페이지 head 에 Jua link 있음
- 레이아웃·컴포넌트 클래스는 perfectedu 와 동일 (`.hero .hero-card .trust .cards .steps .why .feat .quotes .faq .apply .tgrid .tc .tprofile .tcard .tsec` …) + 키즈 전용 `.screen .age-tabs .age-panel .lesson .flow .tform`

## 선생님 데이터 (gen.ps1)
- 원본: `../gwaoe-page/teachers-data.js`, `teachers-search.js`, `teacher-{id}.html` (와와/티칭코칭 코치 750명)
- **선택 기준:** 화상 가능(`c` 에 "화상") AND (유아·아동 코치 `k=1` OR 어떤 과목이든 학년이 유아/초1/초2 부터)
  → 362명 (유아·아동 코치 30명 먼저, 이후 원래 순서)
- 개별 페이지는 원본 페이지의 "선생님 소개 / 지도 과목 / 경력" 섹션을 그대로 가져오고, 방문 지역·학교 목록은 뺌 (방문+화상 선생님은 지역명만 한 줄)
- **재생성:** gwaoe-page 의 선생님 데이터가 바뀌면 아래 실행 (PowerShell 5.1 은 BOM 없는 .ps1 의 한글이 깨지므로 BOM 붙여 실행)
  ```
  printf '\xEF\xBB\xBF' | cat - gen.ps1 > gen_bom.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File gen_bom.ps1 && rm gen_bom.ps1
  ```
  (index.html 의 "360+" 숫자는 손으로 맞출 것)

## 처음 배포 (아직 안 했으면)
1. GitHub 에 `kids-online` 저장소 생성: `gh repo create kids-online --public --source=. --push` (gh 는 `C:\Program Files\GitHub CLI\gh.exe`)
2. 저장소 Settings → Pages → Branch: main / (root)
3. 도메인 연결 시 `CNAME` 파일에 도메인 한 줄 + DNS 에 CNAME 레코드(`x26589334-cpu.github.io`)

## 다음에 할 후보
- 가비아 DNS: A 레코드 185.199.108.153 / .109.153 / .110.153 / .111.153 + www CNAME x26589334-cpu.github.io → GitHub Pages 에서 HTTPS 강제
- 구글 서치콘솔·네이버 서치어드바이저 등록 (meta 태그는 index.html head 에 추가)
- 실제 학부모 후기·수업 사진으로 교체 (현재 후기 3개는 예시 문구)
- 블로그(유아 한글 떼기 시기, 파닉스 시작 나이 등 SEO 글) 추가 — gwaoe-page 의 `.bpost/.article` 스타일 그대로 사용 가능
- 폼 필드명(이름/연락처/학년/분야/선생님성별/수업시간대/선생님/남길말)은 시트 헤더가 되므로 바꾸면 새 컬럼이 생김
