/* ===========================================================
   신청 폼 → 구글 시트 연결 (키즈튜터 · 유아/초등 저학년 화상과외)
   -----------------------------------------------------------
   과외(perfectedu)·픽포스·데일리카네기와 같은 **공용 Apps Script 웹앱**으로 보냅니다.
   → 구글 "웹 문의" 시트(ID 1UUS6le8…)의 **"키즈튜터" 탭**에 저장
     (폼이 sheet=키즈튜터 를 함께 보내고, 스크립트가 그 탭을 찾거나 자동 생성)
   → 구분 컬럼: 키즈튜터-무료체험신청 / 키즈튜터-수업방식-상담신청 / 키즈튜터-선생님지정상담
   ※ 배포된 스크립트가 "허용 탭 목록" 버전이면 ALLOWED_TABS 에 "키즈튜터": true 한 줄 추가
     (없으면 기본 탭 "과외"로 들어감). 참고 사본: google-apps-script.gs
   =========================================================== */

const SHEET_ENDPOINT = "https://script.google.com/macros/s/AKfycbznAb0ZOODlNp-ckR5fvkqtVQijwuJ9Gl0G4KxDrfp-K7zM4fcfMMp5qDhAbwNkvYQG/exec";

function _val(id){ const el = document.getElementById(id); return el ? String(el.value).trim() : ""; }

function _sendToSheet(payload){
  if(!SHEET_ENDPOINT || SHEET_ENDPOINT.indexOf("PASTE_") === 0){
    return Promise.resolve(); // 미연결 시 데모 모드
  }
  return fetch(SHEET_ENDPOINT, {
    method: "POST",
    mode: "no-cors",
    headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
    body: new URLSearchParams(payload).toString()
  });
}

/* opts = { formId, okId, title, required:[id...], fields:{시트컬럼명: inputId} } */
function _wireForm(opts){
  const form = document.getElementById(opts.formId);
  if(!form) return;
  form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    for(const id of opts.required){
      if(!_val(id)){ alert("필수 항목을 모두 입력해 주세요."); const el=document.getElementById(id); if(el) el.focus(); return; }
    }
    const payload = { sheet: "키즈튜터", _form: opts.title, _page: location.pathname, _time: new Date().toLocaleString("ko-KR") };
    for(const col in opts.fields){ payload[col] = _val(opts.fields[col]); }

    const btn = form.querySelector('button[type="submit"], button');
    const orig = btn ? btn.textContent : "";
    if(btn){ btn.disabled = true; btn.textContent = "접수 중…"; }
    try{ await _sendToSheet(payload); }catch(_){ /* no-cors: 응답 못 읽어도 정상 */ }
    const ok = document.getElementById(opts.okId);
    if(ok) ok.style.display = "block";
    if(btn){ btn.textContent = "신청 완료 ✓"; }
  });
}

// 1) 홈 - 무료 체험 수업 신청
_wireForm({
  formId: "applyForm", okId: "okMsg", title: "키즈튜터-무료체험신청",
  required: ["name","phone","age","subject"],
  fields: { 이름:"name", 연락처:"phone", 학년:"age", 분야:"subject", 선생님성별:"gender", 남길말:"memo" }
});

// 2) 수업방식 - 상담 신청
_wireForm({
  formId: "trialForm", okId: "tOk", title: "키즈튜터-수업방식-상담신청",
  required: ["t_name","t_phone","t_age","t_subject"],
  fields: { 이름:"t_name", 연락처:"t_phone", 학년:"t_age", 분야:"t_subject", 수업시간대:"t_time", 남길말:"t_memo" }
});

// 3) 선생님 상세 - 이 선생님으로 상담 신청
_wireForm({
  formId: "teacherForm", okId: "tfOk", title: "키즈튜터-선생님지정상담",
  required: ["f_name","f_phone","f_age"],
  fields: { 이름:"f_name", 연락처:"f_phone", 학년:"f_age", 선생님:"f_teacher", 남길말:"f_memo" }
});
