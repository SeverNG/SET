param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [Parameter(Mandatory=$true)]
    [string]$ExeSourcePath
)

 $ErrorActionPreference = "Stop"

# 1. Создаём папку и копируем exe
 $targetDir = "releases\v$Version"
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
Copy-Item $ExeSourcePath "$targetDir\SET.exe" -Force

# 2. Считаем SHA256
 $hash = (Get-FileHash "$targetDir\SET.exe" -Algorithm SHA256).Hash.ToLower()

# 3. Генерируем манифест
 $manifest = @{
    latestVersion = $Version
    downloadUrl = "https://github.com/SeverNG/SET/raw/main/releases/v$Version/SET.exe"
    checksum = "sha256:$hash"
} | ConvertTo-Json

[System.IO.File]::WriteAllText("manifest.json", $manifest, [System.Text.Encoding]::UTF8)

# 4. Коммит и пуш
git add .
git commit -m "Release v$Version"
git push

Write-Host "Released v$Version. SHA256: $hash" -ForegroundColor Green