<#
.SYNOPSIS
带交互式初始化、PATH自动检测、防抖延时、单配置文件的md2pdf监听脚本
#>




# 强制设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8




# -------------------------- 配置文件路径 --------------------------
$configFile = Join-Path $PSScriptRoot "config.json"
# 脚本所在目录，作为默认监听目录
$defaultWatchDir = $PSScriptRoot
# -----------------------------------------------------------------




# 默认配置
$defaultConfig = [PSCustomObject]@{
    watchDir         = $defaultWatchDir
    templateDir      = ""
    pandocPath       = ""
    sofficePath      = ""
    pollMs           = 700
    debounceMs       = 300
    LastTemplatePath = $null
}




# 加载配置 + 缺失字段自动补齐
function Import-Config {
    if (-not (Test-Path $configFile)) {
        Write-Host "`n[初始化] 创建默认配置" -ForegroundColor Cyan
        # 首次生成配置前自动探测二进制绝对路径
        try{
            $cmdSoffice = Get-Command "soffice.exe" -ErrorAction Stop
            $detectSoffice = $cmdSoffice.Source
        }
        catch{
            Write-Error "初始化失败：未在PATH中找到 soffice.exe (LibreOffice)"
            Write-Host "请安装 LibreOffice 并添加至系统环境变量 PATH`n" -ForegroundColor Yellow
            exit 1
        }
        try{
            $cmdPandoc = Get-Command "pandoc.exe" -ErrorAction Stop
            $detectPandoc  = $cmdPandoc.Source
        }
        catch{
            Write-Error "初始化失败：未在PATH中找到 pandoc.exe"
            Write-Host "请安装 Pandoc 并添加至系统环境变量 PATH`n" -ForegroundColor Yellow
            exit 1
        }
        $defaultConfig.sofficePath = $detectSoffice
        $defaultConfig.pandocPath  = $detectPandoc



        # 探测结果区块（绿色输出，新增 watchDir 参数说明）
        Write-Host "`n[探测结果]" -ForegroundColor Green
        Write-Host '  "watchDir": "'$defaultWatchDir'",' -ForegroundColor Green
        Write-Host "       ↳ Markdown监听目录，默认脚本所在目录，可在配置向导中自定义或修改配置文件" -ForegroundColor Green
        Write-Host '  "pandocPath": "'$detectPandoc'",' -ForegroundColor Green
        Write-Host "       ↳ Pandoc可执行文件路径，用于Markdown转docx" -ForegroundColor Green
        Write-Host '  "sofficePath": "'$detectSoffice'",' -ForegroundColor Green
        Write-Host "       ↳ LibreOffice可执行文件路径，用于docx转PDF" -ForegroundColor Green
        Write-Host '  "pollMs": '$defaultConfig.pollMs',' -ForegroundColor Green
        Write-Host "       ↳ 文件轮询间隔(毫秒)，多久扫描一次md文件变更" -ForegroundColor Green
        Write-Host '  "debounceMs": '$defaultConfig.debounceMs -ForegroundColor Green
        Write-Host "       ↳ 防抖延时(毫秒)，文件停止改动后等待多久再开始转换`n" -ForegroundColor Green



        $defaultConfig | ConvertTo-Json -Depth 10 | Out-File $configFile -Encoding utf8
    }
    $rawJson = Get-Content $configFile -Raw
    $cfg = $rawJson | ConvertFrom-Json




    # 补齐新增字段
    $requiredProps = @("pandocPath","sofficePath","watchDir","debounceMs", "pollMs", "LastTemplatePath")
    foreach ($prop in $requiredProps) {
        if (-not $cfg.PSObject.Properties.Name.Contains($prop)) {
            $val = switch ($prop) {
                "pandocPath" { "pandoc.exe" }
                "sofficePath" { "soffice.exe" }
                "watchDir" { $defaultWatchDir }
                "debounceMs" { 300 }
                "pollMs" { 700 }
                "LastTemplatePath" { $null }
            }
            $cfg | Add-Member -MemberType NoteProperty -Name $prop -Value $val -Force
        }
    }
    return $cfg
}




# 交互式输入目录 + 合法性校验
function Read-ValidDirectory {
    param(
        [string]$promptText,
        [string]$defaultDir
    )
    while ($true) {
        if (-not [string]::IsNullOrWhiteSpace($defaultDir)) {
            $inputStr = Read-Host -Prompt "$promptText (直接回车使用默认: $defaultDir)"
            if ([string]::IsNullOrWhiteSpace($inputStr)){
                $inputStr = $defaultDir
            }
        }else{
            $inputStr = Read-Host -Prompt $promptText
        }
        # 去除首尾空白
        $inputStr = $inputStr.Trim()
        # 自动补全相对路径转绝对路径
        $absPath = [System.IO.Path]::GetFullPath($inputStr)
        if ((Test-Path $absPath -PathType Container)) {
            return $absPath
        }
        Write-Host "目录不存在: $absPath ,请核对路径`n" -ForegroundColor Red
    }
}




# 加载配置
$config = Import-Config




# watchDir为空 → 进入交互式配置向导
if ([string]::IsNullOrWhiteSpace($config.watchDir) -or [string]::IsNullOrWhiteSpace($config.templateDir)) {
    Write-Host "`n===== 初始化运行配置向导 =====" -ForegroundColor Cyan
    # 默认值 = 脚本所在目录
    $config.watchDir = Read-ValidDirectory -promptText "请输入监听md文件目录" -defaultDir $defaultWatchDir
    $config.templateDir = Read-ValidDirectory -promptText "请输入docx模板目录" -defaultDir ""
    # 写入配置
    $config | ConvertTo-Json -Depth 10 | Out-File $configFile -Encoding utf8
    Write-Host "✅ 目录配置已保存至 config.json`n" -ForegroundColor Green
}




$watchDir = $config.watchDir
$templateDir = $config.templateDir
$sofficePath = $config.sofficePath
$pandocPath = $config.pandocPath
$pollMs = $config.pollMs
$debounceMs = $config.debounceMs
$lastSelectedTemplate = $config.LastTemplatePath





<#
工具路径检测函数
优先校验配置内路径；无效则通过 Get-Command 在PATH中查找
#>
function Resolve-BinaryPath {
    param(
        [string]$currentConfigPath,
        [string]$exeName
    )
    # 如果配置已经是有效绝对路径，直接返回
    if (-not [string]::IsNullOrWhiteSpace($currentConfigPath)) {
        if ((Split-Path $currentConfigPath -IsAbsolute) -and (Test-Path $currentConfigPath)) {
            return $currentConfigPath
        }
    }
    # 通过系统PATH查找
    $cmd = Get-Command $exeName -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }
    return $null
}




# ============ soffice.exe 检测 ============
$detectedSoffice = Resolve-BinaryPath $sofficePath "soffice.exe"
if ($detectedSoffice) {
    if ($sofficePath -ne $detectedSoffice) {
        Write-Host "[自动检测] soffice.exe -> $detectedSoffice`n" -ForegroundColor Cyan
        $config.sofficePath = $detectedSoffice
        $sofficePath = $detectedSoffice
    }
}
else {
    Write-Error "未在系统PATH中找到 soffice.exe (LibreOffice)"
    Write-Host "请安装 LibreOffice 并添加至系统环境变量 PATH`n" -ForegroundColor Yellow
    exit 1
}




# ============ pandoc.exe 检测 ============
$detectedPandoc = Resolve-BinaryPath $pandocPath "pandoc.exe"
if ($detectedPandoc) {
    if ($pandocPath -ne $detectedPandoc) {
        Write-Host "[自动检测] pandoc.exe -> $detectedPandoc`n" -ForegroundColor Cyan
        $config.pandocPath = $detectedPandoc
        $pandocPath = $detectedPandoc
    }
}
else {
    Write-Error "未在系统PATH中找到 pandoc.exe"
    Write-Host "请安装 Pandoc 并添加至系统环境变量 PATH`n" -ForegroundColor Yellow
    exit 1
}




# 检测发生变更则回写配置文件
$config | ConvertTo-Json -Depth 10 | Out-File $configFile -Encoding utf8




# ============ 二次校验目录(防止用户手动改坏json) ============
if (-not (Test-Path $templateDir -PathType Container)) {
    Write-Error "模板文件夹不存在：$templateDir"
    Write-Host "检查 config.json templateDir 路径`n" -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path $watchDir -PathType Container)) {
    Write-Error "监听文件夹不存在：$watchDir"
    Write-Host "检查 config.json watchDir 路径`n" -ForegroundColor Yellow
    exit 1
}




# 获取目录下全部docx模板
$templateFiles = Get-ChildItem -Path $templateDir -Filter "*.docx" -File
if (-not $templateFiles) {
    Write-Error "模板目录没有找到任何docx文件：$templateDir"
    exit 1
}




Write-Host "`n===== 可用docx模板列表 =====" -ForegroundColor Cyan
for ($i = 0; $i -lt $templateFiles.Count; $i++) {
    $f = $templateFiles[$i]
    Write-Host "[$($i+1)] $($f.Name)"
}




$defaultHint = if ($lastSelectedTemplate -and (Test-Path $lastSelectedTemplate)) {
    $n = Split-Path $lastSelectedTemplate -Leaf
    "直接回车使用上次模板: $n"
}
else {
    "直接回车选择第1项"
}
Write-Host "`n请输入模板序号，$defaultHint" -ForegroundColor Yellow
$inputVal = Read-Host




# 用户选择逻辑
if ([string]::IsNullOrWhiteSpace($inputVal)) {
    if ($lastSelectedTemplate -and (Test-Path $lastSelectedTemplate)) {
        $templatePath = $lastSelectedTemplate
        Write-Host "✅ 使用上次保存模板 $(Split-Path $templatePath -Leaf)`n" -ForegroundColor Green
    }
    else {
        $templatePath = $templateFiles[0].FullName
        Write-Host "✅ 默认选择第一项模板 $(Split-Path $templatePath -Leaf)`n" -ForegroundColor Green
    }
}
else {
    $idx = [int]$inputVal - 1
    if ($idx -ge 0 -and $idx -lt $templateFiles.Count) {
        $templatePath = $templateFiles[$idx].FullName
        Write-Host "✅ 选中模板 $(Split-Path $templatePath -Leaf)`n" -ForegroundColor Green
    }
    else {
        Write-Error "序号超出范围"
        exit 1
    }
}




# 更新配置里面 LastTemplatePath，回写到json
$config.LastTemplatePath = $templatePath
$config | ConvertTo-Json -Depth 10 | Out-File $configFile -Encoding utf8




# 记录md文件上一次的文件大小
$lastFileSize = @{}
# 防抖计时器: key=文件全路径, value=最后一次变更时间戳
$debounceTrigger = @{}




# 单次构建逻辑
function Invoke-Build {
    param([string]$mdPath)
    Write-Host "`n>>>> 检测文件变更: $mdPath" -ForegroundColor Green




    $docx = [System.IO.Path]::ChangeExtension($mdPath, ".docx")
    $pandocArgs = @($mdPath, '-o', $docx, '--reference-doc', $templatePath)
    & $pandocPath @pandocArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "pandoc转换失败 $mdPath"
        return
    }
    Write-Host "✅ 已生成 $docx"

    # PDF输出至md源文件同级目录
    $sourceDir = Split-Path $mdPath -Parent
    & $sofficePath --headless --convert-to pdf $docx --outdir $sourceDir
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "LibreOffice转PDF失败 $docx"
        return
    }
    Write-Host "✅ PDF生成完成"
}




Write-Host "[监听启动] 递归监控目录 $watchDir 及其子目录下 *.md 文件大小变化" -ForegroundColor Cyan
Write-Host "防抖延时: $debounceMs ms  当前生效模板: $templatePath`n" -ForegroundColor Gray
Write-Host "按 Ctrl+C 退出`n" -ForegroundColor Yellow




try {
    while ($true) {
        $now = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
        # 增加-Recurse 参数，递归扫描全部子目录
        $mdFiles = Get-ChildItem -Path $watchDir -Filter "*.md" -File -Recurse




        foreach ($file in $mdFiles) {
            $currentSize = $file.Length
            $key = $file.FullName




            # 文件大小发生改变，刷新防抖时间
            if (-not $lastFileSize.ContainsKey($key) -or $lastFileSize[$key] -ne $currentSize) {
                $lastFileSize[$key] = $currentSize
                $debounceTrigger[$key] = $now
            }




            # 满足防抖时间条件才执行编译
            if ($debounceTrigger.ContainsKey($key)) {
                $elapsed = $now - $debounceTrigger[$key]
                if ($elapsed -ge $debounceMs) {
                    Invoke-Build -mdPath $key
                    $debounceTrigger.Remove($key)
                }
            }
        }
        Start-Sleep -Milliseconds $pollMs
    }
}
finally {
    Write-Host "`n监听脚本已退出"
}
