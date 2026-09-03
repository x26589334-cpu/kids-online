# og-image.png (1200x630) + apple-touch-icon.png (180x180) 생성 — System.Drawing 사용
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Brush([string]$hex) { return [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($hex)) }
function Pick([string[]]$names, [single]$size, [System.Drawing.FontStyle]$style) {
  foreach ($n in $names) { try { $f = [System.Drawing.Font]::new($n, $size, $style, [System.Drawing.GraphicsUnit]::Pixel); if ($f.Name -eq $n) { return $f } } catch {} }
  return [System.Drawing.Font]::new("Arial", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}
$korFonts = @("Malgun Gothic", "맑은 고딕", "NanumGothic", "Gulim")

# ---- OG image ----
$w = 1200; $h = 630
$bmp = [System.Drawing.Bitmap]::new($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = "AntiAlias"; $g.TextRenderingHint = "AntiAliasGridFit"
$g.Clear([System.Drawing.ColorTranslator]::FromHtml("#fff7ee"))
# 배경 원(장식)
$g.FillEllipse((Brush "#ffe9d2"), 820, -160, 560, 560)
$g.FillEllipse((Brush "#e3f7f2"), -140, 380, 420, 420)
$g.FillEllipse((Brush "#fff3cf"), 700, 430, 300, 300)
# 로고 박스
$path = [System.Drawing.Drawing2D.GraphicsPath]::new()
$r = 22; $x = 90; $y = 90; $s = 88
$path.AddArc($x, $y, $r*2, $r*2, 180, 90); $path.AddArc($x+$s-$r*2, $y, $r*2, $r*2, 270, 90)
$path.AddArc($x+$s-$r*2, $y+$s-$r*2, $r*2, $r*2, 0, 90); $path.AddArc($x, $y+$s-$r*2, $r*2, $r*2, 90, 90); $path.CloseFigure()
$lg = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Point]::new($x,$y), [System.Drawing.Point]::new(($x+$s),($y+$s)), [System.Drawing.ColorTranslator]::FromHtml("#ff7a1f"), [System.Drawing.ColorTranslator]::FromHtml("#ffa94d"))
$g.FillPath($lg, $path)
$fLogo = [System.Drawing.Font]::new("Arial", 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sf = [System.Drawing.StringFormat]::new(); $sf.Alignment = "Center"; $sf.LineAlignment = "Center"
$g.DrawString("K", $fLogo, (Brush "#ffffff"), ([System.Drawing.RectangleF]::new($x, $y, $s, $s)), $sf)
$fBrand = Pick $korFonts 40 ([System.Drawing.FontStyle]::Bold)
$g.DrawString("키즈튜터", $fBrand, (Brush "#1e2a3f"), 200, 110)
# 헤드라인
$fH = Pick $korFonts 74 ([System.Drawing.FontStyle]::Bold)
$g.DrawString("유아·초등", $fH, (Brush "#1e2a3f"), 84, 235)
$g.DrawString("1:1 화상과외", $fH, (Brush "#ff7a1f"), 84, 325)
$fS = Pick $korFonts 30 ([System.Drawing.FontStyle]::Regular)
$g.DrawString("5세부터 초6까지 · 한글 · 파닉스 · 연산 · 독서 · 입학 준비", $fS, (Brush "#5b6780"), 88, 440)
$fP = Pick $korFonts 28 ([System.Drawing.FontStyle]::Bold)
$g.DrawString("무료 20분 체험  ·  010-6832-1994", $fP, (Brush "#e2620a"), 88, 520)
$bmp.Save((Join-Path $root "og-image.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# ---- apple-touch-icon ----
$s = 180
$bmp = [System.Drawing.Bitmap]::new($s, $s)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = "AntiAlias"; $g.TextRenderingHint = "AntiAliasGridFit"
$lg = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s,$s), [System.Drawing.ColorTranslator]::FromHtml("#ff7a1f"), [System.Drawing.ColorTranslator]::FromHtml("#ffa94d"))
$g.FillRectangle($lg, 0, 0, $s, $s)
$g.FillEllipse((Brush "#ffffff"), 59, 34, 62, 62)
$g.FillPie((Brush "#ffffff"), 30, 100, 120, 130, 180, 180)
$g.FillEllipse((Brush "#ff7a1f"), 76, 58, 8, 8); $g.FillEllipse((Brush "#ff7a1f"), 96, 58, 8, 8)
$pen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml("#ff7a1f"), 4)
$pen.StartCap = "Round"; $pen.EndCap = "Round"
$g.DrawArc($pen, 76, 66, 28, 18, 20, 140)
$bmp.Save((Join-Path $root "apple-touch-icon.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Host "og-image.png / apple-touch-icon.png 생성 완료"
