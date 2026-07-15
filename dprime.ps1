$Host.UI.RawUI.WindowTitle = "dPrime Library Installer by EDE"

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
    Write-Host "[$Type] $Message" -ForegroundColor $foreground -NoNewline:$NoNewline
}

$ProgressPreference = 'Continue'

Log "INFO" "Steam kapatiliyor..."
Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force

$files = @("dwmapi.dll", "xinput1_4.dll")
$missing = $false

foreach ($file in $files) {
    $targetPath = Join-Path $steam $file
    if (!(Test-Path $targetPath)) {
        $missing = $true
        break
    }
}

if (-not $missing) {
    Log "INFO" "Gerekli dosyalar zaten mevcut."
} 
else {
    Log "WARN" "Gerekli dosyalar indiriliyor..."
    
    foreach ($file in $files) {
        $url = "https://dptools.vercel.app/$file"
        $targetPath = Join-Path $steam $file
        
        try {
            Invoke-WebRequest -Uri $url -OutFile $targetPath -UseBasicParsing -ErrorAction Stop
        }
        catch {
            Log "ERR" "$file indirilemedi!"
        }
    }
    
    Log "OK" "Gerekli dosyalar basariyla indirildi."
}

#### dPrime Library İndirme ve Çalıştırma ####
$exeUrl = "https://dptools.vercel.app/dPrime%20Library%201.0.0.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$exeName = "dPrime Library 1.0.0.exe"
$exeFullPath = Join-Path $desktopPath $exeName

Log "LOG" "dPrime Library masaustune indiriliyor..."
Invoke-WebRequest -Uri $exeUrl -OutFile $exeFullPath

if (Test-Path $exeFullPath) {
    Log "OK" "Indirme tamamlandi! Uygulama baslatiliyor..."
    Start-Process -FilePath $exeFullPath
}
else {
    Log "ERR" "dPrime Library indirilemedi."
}

Write-Host
Log "INFO" "Islem tamamlandi. Cikmak icin bir tusa basin..."
$Host.UI.RawUI.FlushInputBuffer()
[void][System.Console]::ReadKey($true)