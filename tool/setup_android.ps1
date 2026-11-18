# 在 Windows 上为现有 Flutter 源码补全 Android 工程。
# 需要先在 PATH 中安装 Flutter 3.35.7+。
#
# 用法（在项目根目录）：
#   powershell -ExecutionPolicy Bypass -File .\tool\setup_android.ps1
#
# 如果已有 android/ 目录，脚本会直接退出，不覆盖你的配置。

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$androidDir = Join-Path $projectRoot "android"

if (Test-Path $androidDir) {
    Write-Host "android/ 已存在，跳过创建。"
    exit 0
}

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutter) {
    throw "未找到 flutter 命令。请先安装 Flutter 3.35.7+ 并加入 PATH。"
}

$tempName = "fitness_log_android_" + [Guid]::NewGuid().ToString("N").Substring(0, 8)
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) $tempName
$tempProject = Join-Path $tempRoot "fitness_log"

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    Write-Host "正在生成 Android 模板：$tempProject"
    & flutter create --platforms=android --org com.example --project-name fitness_log --no-pub $tempProject
    if ($LASTEXITCODE -ne 0) {
        throw "flutter create 失败，退出码 $LASTEXITCODE"
    }

    Copy-Item -Path (Join-Path $tempProject "android") -Destination $projectRoot -Recurse
    Write-Host "已复制 android/ 到项目。"

    # 应用名改成中文；关闭系统云备份，保持“数据只在本机”。
    $manifestPath = Join-Path $projectRoot "android\app\src\main\AndroidManifest.xml"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath -Raw -Encoding UTF8
        $manifest = $manifest -replace 'android:label="[^"]*"', 'android:label="健身记录"'
        if ($manifest -notmatch 'android:allowBackup=') {
            $backupAttribute = '<application' + [Environment]::NewLine + '        android:allowBackup="false"'
            $manifest = $manifest -replace '<application', $backupAttribute
        }
        Set-Content -Path $manifestPath -Value $manifest -Encoding UTF8
    }

    Write-Host ""
    Write-Host "完成。接下来执行："
    Write-Host "  flutter pub get"
    Write-Host "  dart run build_runner build --delete-conflicting-outputs"
    Write-Host "  flutter run"
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
