/* =========================================================================
   구글 "웹 문의" 시트 공용 Apps Script — 사이트별 탭 저장
   (2026-09-03 실제 배포본과 동기화한 사본. 이 파일을 고쳐도 동작은 안 바뀜)
   -------------------------------------------------------------------------
   ▶ 실제 코드 위치: https://script.google.com (구글계정 x26589334@gmail.com)
     또는 "웹 문의" 시트 → 확장 프로그램 → Apps Script
     ※ 이 저장소의 파일은 참고용 사본일 뿐. 진짜 코드는 구글 서버에 있음.

   ▶ 이 웹앱(AKfycbznAb0…) 하나를 6개 사이트가 공용으로 씁니다 — 건드리면 전부 영향
       과외       = perfectedu.co.kr    (gwaoe-page)     → "과외" 탭
       공부의온도  = firststudy.co.kr    (tutoring-site)  → "공부의온도" 탭
       채용       = vinemarketing.co.kr (vine-recruit)   → "채용" 탭
       데일리카네기 = dailycarnegie.com   (daily-carnegie) → "데일리카네기" 탭
       키즈튜터    = kidstutor.co.kr     (kids-online)    → "키즈 튜터" 탭 (띄어쓰기!)
       서포트포스  = hsupporter.com      (pickpos)        → "견적" 탭
     (thebetteredu / intl-school-tutoring / wawa-renewal 은 각자 별도 웹앱)
     doGet 문구가 "vine recruit" 인 건 채용 사이트용으로 처음 만든 흔적.

   ▶ 주의 1: 허용 탭 목록(화이트리스트)이 없습니다.
     폼이 보낸 sheet 값이 그대로 탭 이름이 되고, 없으면 새로 만듭니다.
     → form.js 의 탭 이름에 오타가 나면 기본 탭("과외")으로 떨어지지 않고
       오타 이름의 새 탭이 조용히 생기니, 수정 후 반드시 실제 탭을 확인할 것.

   ▶ 주의 2: 수정 반영은 URL 유지 방식으로만
     편집기에서 코드 교체 → 저장 → [배포] → [배포 관리]
     → 기존 배포 연필(수정) → 버전: 새 버전 → [배포]
     ※ "새 배포" 를 누르면 새 URL 이 생기고, 옛 URL 은 옛 버전 코드로 계속 돌아감
       (2026-09-02 상담이 "업무소통" 탭에 쌓인 사고의 원인). 6개 사이트가 전부 먹통.
   ========================================================================= */

var SHEET_ID   = "1UUS6le8gJTsuvaSDi31ZzuQjA214YD32xJFVgYx9cno";
var SHEET_NAME = "과외"; // sheet 값이 없을 때 기본 탭

function doPost(e) {
  try {
    var ss = SpreadsheetApp.openById(SHEET_ID);
    var p  = (e && e.parameter) ? e.parameter : {};
    var tab = p.sheet || SHEET_NAME;
    var sh = ss.getSheetByName(tab) || ss.insertSheet(tab);
    var when = p._time || new Date().toLocaleString("ko-KR");
    var kind = p._form || "";
    var headers;
    if (sh.getLastRow() === 0) {
      headers = ["접수시각", "구분"];
      for (var k in p) { if (k.charAt(0) === "_" || k === "sheet") continue; headers.push(k); }
      sh.appendRow(headers);
    } else {
      headers = sh.getRange(1, 1, 1, sh.getLastColumn()).getValues()[0];
      for (var k2 in p) {
        if (k2.charAt(0) === "_" || k2 === "sheet") continue;
        if (headers.indexOf(k2) === -1) { headers.push(k2); sh.getRange(1, headers.length).setValue(k2); }
      }
    }
    var row = [];
    for (var i = 0; i < headers.length; i++) {
      var h = headers[i];
      row.push(h === "접수시각" ? when : h === "구분" ? kind : (p[h] != null ? p[h] : ""));
    }
    sh.appendRow(row);
    return ContentService.createTextOutput("ok");
  } catch (err) {
    return ContentService.createTextOutput("error: " + err);
  }
}

function doGet() {
  return ContentService.createTextOutput("ok - vine recruit endpoint alive");
}
