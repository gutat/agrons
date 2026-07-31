# ============================================================
# test-local.ps1 — automated end-to-end test of the upload API
#
# Usage:  powershell -ExecutionPolicy Bypass -File api/test-local.ps1
# Prereq: PHP installed and on PATH (php -v)
# Works with PowerShell 5.1 and 7+
# ============================================================

param(
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root       = Split-Path -Parent $PSScriptRoot
$ApiDir     = Join-Path $Root "api"
$UploadsDir = Join-Path $Root "uploads"
$Base       = "http://localhost:$Port"
$TestImg    = Join-Path $env:TEMP "upload-test.png"

# 1x1 transparent PNG (valid image, passes MIME check)
$PngB64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
[IO.File]::WriteAllBytes($TestImg, [Convert]::FromBase64String($PngB64))

# --- Helpers -----------------------------------------------------------
$pass = 0
$fail = 0

function Assert-Equal([string]$name, [string]$actual, [string]$expected) {
    if ($actual -eq $expected) {
        $script:pass++
        Write-Host "  PASS  $name" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  FAIL  $name (expected $expected, got $actual)" -ForegroundColor Red
    }
}

function Assert-Contains([string]$name, [string]$actual, [string]$needle) {
    if ($actual -like "*$needle*") {
        $script:pass++
        Write-Host "  PASS  $name" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  FAIL  $name (missing '$needle' in: $actual)" -ForegroundColor Red
    }
}

# Send a request, always returning { StatusCode, Content } even on errors
function Send-Request {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers = @{},
        [hashtable]$Form = $null
    )
    $params = @{
        Method          = $Method
        Uri             = $Uri
        Headers         = $Headers
        UseBasicParsing = $true
    }
    if ($Form) { $params.Form = $Form }
    try {
        $resp = Invoke-WebRequest @params
        return @{ StatusCode = [string]$resp.StatusCode; Content = $resp.Content }
    } catch {
        # PS 5.1 throws on non-2xx — extract the actual status
        $status = $null
        if ($_.Exception.Response) {
            $status = [string][int]$_.Exception.Response.StatusCode
        } else {
            $status = "0"
        }
        return @{ StatusCode = $status; Content = "" }
    }
}

# Multipart upload via HttpClient — works on PS 5.1 (Invoke-WebRequest -Form is PS7+)
Add-Type -AssemblyName System.Net.Http

function Send-Upload {
    param(
        [string]$Uri,
        [string]$Token,
        [string]$FilePath,
        [string]$Folder
    )
    try {
        $client = New-Object System.Net.Http.HttpClient
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $fileStream = [System.IO.File]::OpenRead($FilePath)
        $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
        $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/png")
        $content.Add($fileContent, "file", [System.IO.Path]::GetFileName($FilePath))
        $content.Add((New-Object System.Net.Http.StringContent($Folder)), "folder")
        $client.DefaultRequestHeaders.Add("X-Upload-Token", $Token)
        $resp = $client.PostAsync($Uri, $content).Result
        $body = $resp.Content.ReadAsStringAsync().Result
        $client.Dispose()
        $fileStream.Dispose()
        return @{ StatusCode = [string][int]$resp.StatusCode; Content = $body }
    } catch {
        return @{ StatusCode = "0"; Content = "" }
    }
}

# --- Setup -------------------------------------------------------------
Write-Host "=== Upload API local test (port $Port) ===" -ForegroundColor Cyan

# Test keys — the real keys come from .user.ini / admin_settings
$env:UPLOAD_API_KEY    = "test-api-key-123"
$env:UPLOAD_SIGNING_KEY = "test-signing-key-456"

# Reset rate-limit + used-nonce counters from previous runs (local test hygiene).
# PHP's sys_get_temp_dir() points to the same $env:TEMP for this user.
Get-ChildItem (Join-Path $env:TEMP "upl_rt_*") -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem (Join-Path $env:TEMP "upl_used_*") -ErrorAction SilentlyContinue | Remove-Item -Force

# Start PHP built-in server (hidden)
$server = Start-Process php -ArgumentList @("-S", "localhost:$Port", "-t", $ApiDir) -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 2

try {
    # --- 1) Token endpoint ------------------------------------------
    Write-Host "`n[1] Token endpoint" -ForegroundColor Yellow

    # wrong key -> 401
    $r = Send-Request -Method POST -Uri "$Base/upload-token.php" -Headers @{ "X-Api-Key" = "wrong-key" }
    Assert-Equal "wrong key rejected (401)" $r.StatusCode "401"

    # missing key -> 401
    $r = Send-Request -Method POST -Uri "$Base/upload-token.php"
    Assert-Equal "missing key rejected (401)" $r.StatusCode "401"

    # correct key -> 200 + token
    $r = Send-Request -Method POST -Uri "$Base/upload-token.php" -Headers @{ "X-Api-Key" = "test-api-key-123" }
    Assert-Equal "correct key accepted (200)" $r.StatusCode "200"
    $tokenJson = $r.Content | ConvertFrom-Json
    Assert-Contains "response has ok:true" ([string]$tokenJson.ok) "True"
    Assert-Contains "response has token" $tokenJson.token "."
    $script:uploadToken = $tokenJson.token

    # --- 2) Upload endpoint -----------------------------------------
    Write-Host "`n[2] Upload endpoint" -ForegroundColor Yellow

    # no token -> 401
    $r = Send-Upload -Uri "$Base/upload.php" -Token "" -FilePath $TestImg -Folder "products"
    Assert-Equal "upload without token rejected (401)" $r.StatusCode "401"

    # bad token -> 401
    $r = Send-Upload -Uri "$Base/upload.php" -Token "bad.token.value" -FilePath $TestImg -Folder "products"
    Assert-Equal "upload with bad token rejected (401)" $r.StatusCode "401"

    # valid token -> 200 + url
    $r = Send-Upload -Uri "$Base/upload.php" -Token $script:uploadToken -FilePath $TestImg -Folder "products"
    Assert-Equal "upload with valid token accepted (200)" $r.StatusCode "200"
    $uploadJson = $r.Content | ConvertFrom-Json
    Assert-Contains "response has url" $uploadJson.url "/uploads/products/"

    # token replay (same token again) -> 401 (one-time nonce)
    $r = Send-Upload -Uri "$Base/upload.php" -Token $script:uploadToken -FilePath $TestImg -Folder "products"
    Assert-Equal "token replay rejected (401)" $r.StatusCode "401"

    # --- 3) File landed on disk --------------------------------------
    Write-Host "`n[3] File on disk" -ForegroundColor Yellow
    $files = @(Get-ChildItem -Path (Join-Path $UploadsDir "products") -Filter "*.png" -ErrorAction SilentlyContinue)
    if ($files.Count -ge 1) {
        $script:pass++
        Write-Host "  PASS  file saved: $($files[0].Name)" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  FAIL  no file found in uploads/products/" -ForegroundColor Red
    }

} finally {
    # --- Cleanup ------------------------------------------------------
    Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
    Remove-Item $TestImg -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $UploadsDir -ErrorAction SilentlyContinue
}

# --- Summary -----------------------------------------------------------
Write-Host "`n=== Result: $pass passed, $fail failed ===" -ForegroundColor Cyan
if ($fail -gt 0) { exit 1 } else { exit 0 }
