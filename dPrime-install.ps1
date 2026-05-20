$Host.UI.RawUI.WindowTitle = "Steamtools & dPrime Library Installer"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

# Steam dizinini bul
$steam = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam").InstallPath

#### Loglama fonksiyonu ####
function Log {
    param ([string]$Type, [string]$Message, [boolean]$NoNewline = $false)

    $Type = $Type.ToUpper()
    switch ($Type) {
        "OK" { $foreground = "Green" }
        "INFO" { $foreground = "Cyan" }
        "ERR" { $foreground = "Red" }
        "WARN" { $foreground = "Yellow" }
        "LOG" { $foreground = "Magenta" }
        "AUX" { $foreground = "DarkGray" }
        default { $foreground = "White" }
    }

    $date = Get-Date -Format "HH:mm:ss"
    $prefix = if ($NoNewline) { "`r[$date] " } else { "[$date] " }
    Write-Host $prefix -ForegroundColor "Cyan" -NoNewline
    Write-Host [$Type] $Message -ForegroundColor $foreground -NoNewline:$NoNewline
}

$ProgressPreference = 'SilentlyContinue'

Log "INFO" "Steam kapatılıyor..."
Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force


#### Steamtools Kontrol ve Kurulum ####
function CheckSteamtools {
    $files = @( "dwmapi.dll", "xinput1_4.dll" )
    foreach($file in $files) {
        if (!( Test-Path (Join-Path $steam $file) )) {
            return $false
        }
    }
    return $true
}

if ( CheckSteamtools ) {
    Log "INFO" "Steamtools zaten yüklü."
}
else {
    Log "WARN" "Steamtools bulunamadı, arka planda kuruluyor..."
    $script = Invoke-RestMethod "https://luatools.vercel.app/st.ps1"
    $keptLines = @()

    foreach ($line in $script -split "`n") {
        $conditions = @(
            ($line -imatch "Start-Process" -and $line -imatch "steam"),
            ($line -imatch "steam\.exe"),
            ($line -imatch "Start-Sleep" -or $line -imatch "Write-Host"),
            ($line -imatch "cls" -or $line -imatch "exit"),
            ($line -imatch "Stop-Process" -and -not ($line -imatch "Get-Process"))
        )
        
        if (-not($conditions -contains $true)) {
            $keptLines += $line
        }
    }

    $SteamtoolsScript = $keptLines -join "`n"
    
    # Kodu çalıştır
    Invoke-Expression $SteamtoolsScript *> $null

    if ( CheckSteamtools ) {
        Log "OK" "Steamtools başarıyla kuruldu."
    }
    else {
        Log "ERR" "Steamtools kurulumu başarısız oldu!"
    }
}


#### dPrime Library İndirme ve Çalıştırma ####
$exeUrl = "https://dptools.vercel.app/dPrime%20Library%201.0.0.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$exeName = "dPrime Library 1.0.0.exe"
$exeFullPath = Join-Path $desktopPath $exeName

Log "LOG" "dPrime Library masaüstüne indiriliyor..."
Invoke-WebRequest -Uri $exeUrl -OutFile $exeFullPath *> $null

if ( Test-Path $exeFullPath ) {
    Log "OK" "İndirme tamamlandı! Uygulama başlatılıyor..."
    Start-Process -FilePath $exeFullPath
}
else {
    Log "ERR" "Dosya indirilemedi, lütfen linki veya internet bağlantınızı kontrol edin."
}

Write-Host
Log "INFO" "İşlem tamamlandı. Çıkmak için bir tuşa basın..."
[void][System.Console]::ReadKey($true)