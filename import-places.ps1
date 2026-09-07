# =============================================================================
# 공공데이터 CSV → local-places.csv 변환기
#
#  공공데이터포털에서 받은 유치원/학원 CSV 를 그대로 넣으면
#  우리 형식(지역,동,종류,이름)으로 바꿔서 local-places.csv 에 넣어준다.
#  컬럼 이름이 자료마다 달라서 자동으로 찾아낸다. 손으로 고칠 필요 없음.
#
#  쓰는 법
#    1) 받은 CSV 를 이 폴더에 둔다 (예: 유치원현황.csv)
#    2) 아래 실행 (BOM 붙여서)
#       printf '\xEF\xBB\xBF' | cat - import-places.ps1 > _i.ps1 && \
#         powershell -NoProfile -ExecutionPolicy Bypass -File _i.ps1 -Csv "유치원현황.csv" -Type "유치원" && rm _i.ps1
#    3) 그다음 gen-region.ps1 을 돌리면 동네 페이지가 만들어진다
#
#  ※ 선생님이 방문 가능한 지역만 남긴다. 그래야 페이지에 실을 선생님이 있다.
#     (teachers-data.js 의 r 값에 있는 지역만 통과)
#  ※ 이미 local-places.csv 에 있는 것과 겹치면 건너뛴다. 여러 번 돌려도 안전.
# =============================================================================
param(
  [Parameter(Mandatory=$true)][string]$Csv,
  [string]$Type = "유치원"
)
$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($true)   # 엑셀에서 열 수 있게 BOM 포함
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------- 1) 선생님이 방문 가능한 지역 목록 ----------
$tjs = [IO.File]::ReadAllText((Join-Path $root "teachers-data.js"), [Text.Encoding]::UTF8)
$regions = @{}
foreach ($m in ([regex]'[,{]r:"([^"]*)"').Matches($tjs)) {
  foreach ($one in ($m.Groups[1].Value -split '\|')) {
    $one = $one.Trim()
    if ($one) { $regions[$one] = $true }
  }
}
Write-Host "선생님 방문 지역 $($regions.Count)곳을 기준으로 거릅니다."

# ---------- 2) 시도 이름 줄이기 ----------
$sidoMap = @{
  "서울특별시"="서울"; "부산광역시"="부산"; "대구광역시"="대구"; "인천광역시"="인천"
  "광주광역시"="광주"; "대전광역시"="대전"; "울산광역시"="울산"; "세종특별자치시"="세종"
  "경기도"="경기"; "강원도"="강원"; "강원특별자치도"="강원"
  "충청북도"="충북"; "충청남도"="충남"; "전라북도"="전북"; "전북특별자치도"="전북"
  "전라남도"="전남"; "경상북도"="경북"; "경상남도"="경남"; "제주특별자치도"="제주"
}

# 주소 한 줄 -> "서울 노원구" / "경기 고양 덕양구" 같은 우리 형식으로
function ToRegion([string]$addr) {
  if (-not $addr) { return $null }
  $t = ($addr -replace '\s+', ' ').Trim()
  $parts = $t -split ' '
  if ($parts.Count -lt 2) { return $null }
  $sido = $sidoMap[$parts[0]]
  if (-not $sido) { return $null }
  # 시/군/구 조각 모으기 ("고양시 덕양구" 처럼 두 개일 수 있음)
  $names = @()
  for ($i = 1; $i -lt [Math]::Min($parts.Count, 4); $i++) {
    if ($parts[$i] -match '(시|군|구)$') { $names += ($parts[$i] -replace '시$', '') }
    else { break }
  }
  if ($names.Count -eq 0) { return $null }
  return ($sido + " " + ($names -join " ")).Trim()
}

# 주소에서 동/읍/면 뽑기
function ToDong([string]$addr) {
  if ($addr -match '([가-힣0-9]+(?:동|읍|면))(?:\s|$)') { return $Matches[1] }
  return ""
}

# ---------- 3) CSV 읽기 (인코딩 자동 시도) ----------
$csvPath = Join-Path $root $Csv
if (-not (Test-Path $csvPath)) { Write-Host "파일이 없습니다: $csvPath"; exit 1 }
$rows = $null
foreach ($enc in @("UTF8", "Default")) {   # Default = 윈도우 한글(CP949). 공공데이터는 대개 이쪽
  try {
    $try = @(Import-Csv -Path $csvPath -Encoding $enc)
    if ($try.Count -gt 0) {
      $cols = $try[0].PSObject.Properties.Name -join " "
      if ($cols -match '[가-힣]') { $rows = $try; Write-Host "인코딩: $enc"; break }
    }
  } catch {}
}
if (-not $rows) { Write-Host "CSV 를 읽지 못했습니다. 엑셀에서 열어 'CSV UTF-8'로 다시 저장해 보세요."; exit 1 }
Write-Host "CSV $($rows.Count)줄 읽음"

# ---------- 4) 이름/주소 컬럼 자동 찾기 ----------
$colNames = $rows[0].PSObject.Properties.Name
$nameCol = $colNames | Where-Object { $_ -match '유치원명|원명|기관명|학원명|사업장명|시설명|상호' } | Select-Object -First 1
$addrCol = $colNames | Where-Object { $_ -match '도로명.*주소|소재지.*주소|^주소$|지번.*주소' } | Select-Object -First 1
if (-not $nameCol) { $nameCol = $colNames | Where-Object { $_ -match '명$' } | Select-Object -First 1 }
if (-not $nameCol -or -not $addrCol) {
  Write-Host "이름/주소 컬럼을 못 찾았습니다. 이 파일의 컬럼은 다음과 같습니다:"
  Write-Host ("  " + ($colNames -join " | "))
  exit 1
}
Write-Host "이름 컬럼: $nameCol / 주소 컬럼: $addrCol"

# ---------- 5) 기존 local-places.csv ----------
$outPath = Join-Path $root "local-places.csv"
$existing = @{}
$lines = @()
if (Test-Path $outPath) {
  $old = @(Import-Csv -Path $outPath -Encoding UTF8)
  foreach ($o in $old) {
    $key = "$($o.지역)|$($o.종류)|$($o.이름)"
    if (-not $existing.ContainsKey($key)) {
      $existing[$key] = $true
      $lines += [pscustomobject]@{ 지역=$o.지역; 동=$o.동; 종류=$o.종류; 이름=$o.이름 }
    }
  }
  Write-Host "기존 $($lines.Count)건 유지"
}

# ---------- 6) 변환 ----------
$added = 0; $skipRegion = 0; $skipDup = 0
foreach ($r in $rows) {
  $nm = ("" + $r.$nameCol).Trim()
  $ad = ("" + $r.$addrCol).Trim()
  if (-not $nm -or -not $ad) { continue }
  $reg = ToRegion $ad
  if (-not $reg -or -not $regions.ContainsKey($reg)) { $skipRegion++; continue }
  $key = "$reg|$Type|$nm"
  if ($existing.ContainsKey($key)) { $skipDup++; continue }
  $existing[$key] = $true
  $lines += [pscustomobject]@{ 지역=$reg; 동=(ToDong $ad); 종류=$Type; 이름=$nm }
  $added++
}

# ---------- 7) 저장 ----------
$sorted = $lines | Sort-Object 지역, 종류, 동, 이름
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("지역,동,종류,이름")
foreach ($l in $sorted) {
  $vals = @($l.지역, $l.동, $l.종류, $l.이름) | ForEach-Object {
    $v = "" + $_
    if ($v -match '[",]') { '"' + ($v -replace '"', '""') + '"' } else { $v }
  }
  [void]$sb.AppendLine($vals -join ",")
}
[IO.File]::WriteAllText($outPath, $sb.ToString(), $utf8)

Write-Host ""
Write-Host "새로 넣은 것       : $added 건"
Write-Host "선생님 없는 지역   : $skipRegion 건 (건너뜀)"
Write-Host "이미 있던 것       : $skipDup 건 (건너뜀)"
Write-Host "local-places.csv   : 총 $($sorted.Count) 건 / 지역 $(($sorted | Select-Object -ExpandProperty 지역 -Unique).Count) 곳"
Write-Host ""
Write-Host "다음: gen-region.ps1 을 돌리면 동네 페이지가 만들어집니다."
