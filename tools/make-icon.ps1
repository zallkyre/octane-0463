# Generates ui\assets\octane.ico (256x256, PNG-compressed).
# Demon-octane: red ring + swoosh, two horns, angry eyes and a wide grin.
# Bold shapes on purpose so it stays readable at 16-32 px.
Add-Type -AssemblyName System.Drawing

$S = 256
$bmp = New-Object System.Drawing.Bitmap($S, $S)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

function P([float]$x, [float]$y) { New-Object System.Drawing.PointF($x, $y) }
function Col([int]$r, [int]$gg, [int]$b, [int]$a = 255) {
    [System.Drawing.Color]::FromArgb($a, $r, $gg, $b)
}

# --- tile
$tile = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = 54.0
$tile.AddArc(3, 3, $r, $r, 180, 90)
$tile.AddArc($S - 3 - $r, 3, $r, $r, 270, 90)
$tile.AddArc($S - 3 - $r, $S - 3 - $r, $r, $r, 0, 90)
$tile.AddArc(3, $S - 3 - $r, $r, $r, 90, 90)
$tile.CloseFigure()
$g.FillPath((New-Object System.Drawing.SolidBrush((Col 14 12 16))), $tile)
$g.DrawPath((New-Object System.Drawing.Pen((Col 58 40 44), 3)), $tile)

# --- red glow behind the mark
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(28, 34, 200, 196)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor = Col 255 60 60 110
$glow.SurroundColors = @((Col 255 60 60 0))
$g.FillPath($glow, $glowPath)

$red = Col 255 60 60
$darkRed = Col 168 16 24

# --- swoosh (behind the ring)
$g.TranslateTransform(128, 138)
$g.RotateTransform(-18)
$swooshRect = New-Object System.Drawing.RectangleF(-118, -34, 236, 68)
$g.DrawEllipse((New-Object System.Drawing.Pen($darkRed, 13)), $swooshRect)
$g.ResetTransform()

# --- horns (rotated triangles behind the ring's top edge)
$hornBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (P 60 20), (P 120 90), (Col 255 90 90), $darkRed)
$left = New-Object System.Drawing.Drawing2D.GraphicsPath
$left.AddPolygon(@((P 74 74), (P 44 12), (P 116 56)))
$right = New-Object System.Drawing.Drawing2D.GraphicsPath
$right.AddPolygon(@((P 182 74), (P 212 12), (P 140 56)))
$g.FillPath($hornBrush, $left)
$g.FillPath($hornBrush, $right)

# --- the ring (thick so it reads small)
$ring = New-Object System.Drawing.Drawing2D.GraphicsPath
$ring.AddEllipse(46, 56, 164, 164)
$ringPen = New-Object System.Drawing.Pen($red, 30)
$ringPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawPath($ringPen, $ring)

# inner highlight arc for depth
$hi = New-Object System.Drawing.Drawing2D.GraphicsPath
$hi.AddArc(46, 56, 164, 164, 190, 110)
$g.DrawPath((New-Object System.Drawing.Pen((Col 255 130 130), 8)), $hi)

# --- dark face plate inside the ring
$face = New-Object System.Drawing.Drawing2D.GraphicsPath
$face.AddEllipse(72, 82, 112, 112)
$g.FillPath((New-Object System.Drawing.SolidBrush((Col 22 14 16))), $face)

# --- eyes: bright, slanted
$eyeBrush = New-Object System.Drawing.SolidBrush((Col 255 236 236))
$eyeL = New-Object System.Drawing.Drawing2D.GraphicsPath
$eyeL.AddPolygon(@((P 92 122), (P 122 114), (P 122 134), (P 92 138)))
$eyeR = New-Object System.Drawing.Drawing2D.GraphicsPath
$eyeR.AddPolygon(@((P 164 122), (P 134 114), (P 134 134), (P 164 138)))
$g.FillPath($eyeBrush, $eyeL)
$g.FillPath($eyeBrush, $eyeR)

# pupils
$pupil = New-Object System.Drawing.SolidBrush((Col 180 16 24))
$g.FillEllipse($pupil, 100, 121, 12, 12)
$g.FillEllipse($pupil, 144, 121, 12, 12)

# --- grin: one clean curve, no notch
$smile = New-Object System.Drawing.Drawing2D.GraphicsPath
$smile.AddBezier((P 96 152), (P 112 176), (P 144 176), (P 160 150))
$g.DrawPath((New-Object System.Drawing.Pen((Col 255 236 236), 12)), $smile)

# two small fangs, offset from the centre so they never read as a cleft
$fangBrush = New-Object System.Drawing.SolidBrush((Col 255 236 236))
$f1 = New-Object System.Drawing.Drawing2D.GraphicsPath
$f1.AddPolygon(@((P 108 162), (P 118 162), (P 112 174)))
$f2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$f2.AddPolygon(@((P 140 162), (P 150 162), (P 146 174)))
$g.FillPath($fangBrush, $f1)
$g.FillPath($fangBrush, $f2)

$g.Dispose()

# --- pack into ICO
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$png = $ms.ToArray()
$bmp.Dispose()

$out = Join-Path $PSScriptRoot "..\ui\assets\octane.ico"
New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null

$fs = [IO.File]::Create($out)
$bw = New-Object IO.BinaryWriter($fs)
$bw.Write([UInt16]0); $bw.Write([UInt16]1); $bw.Write([UInt16]1)
$bw.Write([Byte]0); $bw.Write([Byte]0); $bw.Write([Byte]0); $bw.Write([Byte]0)
$bw.Write([UInt16]1); $bw.Write([UInt16]32)
$bw.Write([UInt32]$png.Length); $bw.Write([UInt32]22)
$bw.Write($png)
$bw.Close()

Write-Host ("icon written: " + (Resolve-Path $out) + "  " + (Get-Item $out).Length + " bytes")
