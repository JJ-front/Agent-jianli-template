param(
  [string]$Name = 'resume-agent-ai-app'
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$tex = Join-Path $PSScriptRoot "$Name.tex"
if (-not (Test-Path $tex)) { throw "Missing TeX source: $tex" }

$candidates = @(
  'C:\Users\xiaolei520\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe'
  'C:\Users\xiaolei520\AppData\Local\MiKTeXPortable\texmfs\install\miktex\bin\x64\xelatex.exe'
)
$xelatexPath = $null
foreach ($c in $candidates) {
  if (Test-Path -LiteralPath $c) { $xelatexPath = (Resolve-Path -LiteralPath $c).Path; break }
}
if (-not $xelatexPath) {
  $cmd = Get-Command xelatex -ErrorAction SilentlyContinue
  if ($cmd) { $xelatexPath = $cmd.Source }
}
if (-not $xelatexPath -or -not (Test-Path -LiteralPath $xelatexPath)) {
  throw 'xelatex was not found. Install MiKTeX and reopen PowerShell.'
}

$env:MIKTEX_USERCONFIG = Join-Path $PSScriptRoot '.miktex-config'
$env:MIKTEX_USERDATA = Join-Path $PSScriptRoot '.miktex-data'
New-Item -ItemType Directory -Force $env:MIKTEX_USERCONFIG, $env:MIKTEX_USERDATA | Out-Null
Write-Host "Using: $xelatexPath"
$cmdLine = '"' + $xelatexPath + '" -interaction=nonstopmode -halt-on-error -file-line-error "' + $tex + '"'
& $env:ComSpec /d /s /c $cmdLine
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $env:ComSpec /d /s /c $cmdLine
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$pdf = Join-Path $PSScriptRoot "$Name.pdf"
if (-not (Test-Path $pdf)) { throw "Compilation finished without creating $Name.pdf" }
Write-Host "Generated: $pdf"
