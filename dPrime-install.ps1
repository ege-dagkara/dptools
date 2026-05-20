# =========================
# DPRİME LİBRARY DOWNLOADER + INSTALLER
# =========================

$url = "https://dptools.vercel.app/dPrime%20Library%201.0.0.exe"

$desktop = [Environment]::GetFolderPath("Desktop")
$installerPath = Join-Path $env:TEMP "installer.exe"
$installFolder = Join-Path $desktop "dPrime Library"

function Log($msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Cyan
}

Log "İndirme başlıyor..."

# Progress bar ile download
$webClient = New-Object System.Net.WebClient

$webClient.DownloadProgressChanged += {
    param($sender, $e)
    Write-Progress -Activity "İndiriliyor..." `
        -Status "$($e.ProgressPercentage)% tamamlandı" `
        -PercentComplete $e.ProgressPercentage
}

$webClient.DownloadFileCompleted += {
    Write-Progress -Activity "İndiriliyor..." -Completed
}

$webClient.DownloadFileAsync($url, $installerPath)

# download bitene kadar bekle
while ($webClient.IsBusy) {
    Start-Sleep -Milliseconds 200
}

Log "İndirme tamamlandı."

# Kurulum klasörü
if (!(Test-Path $installFolder)) {
    New-Item -ItemType Directory -Path $installFolder | Out-Null
}

Log "Kurulum başlıyor..."

# Sessiz kurulum denemesi (çoğu exe destekler)
Start-Process $installerPath -ArgumentList "/S /silent /verysilent" -Wait

Log "Kurulum tamamlandı."

# Çalıştır
Log "Program çalıştırılıyor..."
Start-Process $installerPath