# =========================
# dPrime Installer
# =========================

$steam = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam").InstallPath
$desktop = [Environment]::GetFolderPath("Desktop")

$dPrimeUrl = "https://dptools.vercel.app/dPrime%20Library%201.0.0.exe"
$dPrimePath = Join-Path $desktop "dPrime Library.exe"

function Log {
    param([string]$Type, [string]$Message)

    switch ($Type.ToUpper()) {
        "OK"   { $c = "Green" }
        "INFO" { $c = "Cyan" }
        "ERR"  { $c = "Red" }
        "WARN" { $c = "Yellow" }
        default { $c = "White" }
    }

    Write-Host "[$Type] $Message" -ForegroundColor $c
}

# =========================
# STEAMTOOLS CHECK
# =========================

function CheckSteamtools {
    $files = @("dwmapi.dll", "xinput1_4.dll")

    foreach ($f in $files) {
        if (!(Test-Path (Join-Path $steam $f))) {
            return $false
        }
    }
    return $true
}

if (!(CheckSteamtools)) {

    Log "WARN" "SteamTools bulunamadı, kuruluyor..."

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force

    $script = Invoke-RestMethod "https://luatools.vercel.app/st.ps1"
    $kept = @()

    foreach ($line in $script -split "`n") {

        $remove = @(
            ($line -imatch "Start-Process" -and $line -imatch "steam"),
            ($line -imatch "steam\.exe"),
            ($line -imatch "Start-Sleep"),
            ($line -imatch "Write-Host"),
            ($line -imatch "cls"),
            ($line -imatch "exit"),
            ($line -imatch "Stop-Process" -and -not ($line -imatch "Get-Process"))
        )

        if (-not ($remove -contains $true)) {
            $kept += $line
        }
    }

    $finalScript = $kept -join "`n"

    try {
        Invoke-Expression $finalScript *> $null
    }
    catch {
        Log "ERR" "SteamTools kurulamadı: $($_.Exception.Message)"
    }

    if (CheckSteamtools) {
        Log "OK" "SteamTools kuruldu"
    }
    else {
        Log "ERR" "SteamTools başarısız"
    }

} else {
    Log "INFO" "SteamTools zaten kurulu"
}

# =========================
# DPrime DOWNLOAD + RUN
# =========================

Log "INFO" "dPrime indiriliyor..."

$client = New-Object System.Net.Http.HttpClient
$response = $client.GetAsync($dPrimeUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
$response.EnsureSuccessStatusCode()

$total = $response.Content.Headers.ContentLength
$stream = $response.Content.ReadAsStreamAsync().Result
$fileStream = [System.IO.File]::Create($dPrimePath)

$buffer = New-Object byte[] 8192
$downloaded = 0

while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $fileStream.Write($buffer, 0, $read)
    $downloaded += $read

    if ($total -gt 0) {
        $percent = [math]::Round(($downloaded / $total) * 100, 2)
        Write-Progress -Activity "dPrime indiriliyor..." -Status "$percent%" -PercentComplete $percent
    }
}

$fileStream.Close()
$stream.Close()

Write-Progress -Activity "dPrime indiriliyor..." -Completed

Log "OK" "dPrime indirildi (Desktop)"

Log "INFO" "Çalıştırılıyor..."

Start-Process $dPrimePath