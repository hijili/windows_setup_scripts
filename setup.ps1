function install_choco {
    # install chocolatey: ref https://chocolatey.org/docs/installation
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    } catch {
        Write-Error("なんかエラー: " + $_.Exception)
    }
}

function install_softwares_by_choco {
    $softwares = @()
    $list = "applist.txt"
    foreach ($line in Get-Content $list) {
        if ( $line -match "^#") { continue }
        if ( $line -match "^$") { continue }
        $softwares += $line
    }
    foreach ($soft in $softwares) {
        Write-Output("[INFO] exec: cinst -y $soft")
        cinst -y $soft
    }
}
function update_softwares_by_choco {
    $excludes = @()
    $list = "exclude_update_list.txt"
    $opt = ""
    if (Test-Path $list) {
        foreach ($line in Get-Content $list) {
            if ( $line -match "^#") { continue }
            if ( $line -match "^$") { continue }
            $excludes += $line
        }
        if ($excludes.Length -gt 0) {
            $opt = "--except=" + ($excludes -join ",")
        }
    }
    Write-Output("[INFO] exec: choco upgrade -y all $opt")
    choco upgrade -y all $opt
}

# ごくごく個人的な設定集
function setup_configs_for_myself {
    # CapsとCtlの入れ替え
    # ref: https://mk-55.hatenablog.com/entry/2015/10/15/020000
    Write-Output("[INFO] modify registory: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout")
    Set-ItemProperty `
        "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
        -name "Scancode Map" -value (`
            0x00, 0x00, 0x00, 0x00, # header version[4byte]
        0x00, 0x00, 0x00, 0x00, # flags[4byte]
        0x02, 0x00, 0x00, 0x00, # エントリ数（terminateを含んだ数)
        0x1D, 0x00, 0x3A, 0x00, # CapsLock(00 1D)を左ctrl(00 3A)のキーへ変更
        0x00, 0x00, 0x00, 0x00 ` # terminate (終了)
    ) -type binary

    # デスクトップアイコンの縦の間隔
    Write-Output("[INFO] modify registory: HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics")
    # ref: https://kazooblogging.com/windows10-iconspace/
    Set-ItemProperty "Registry::HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" `
        -name "IconVerticalSpacing" -value (-1030) -type string
    # デスクトップアイコンの横の間隔
    Set-ItemProperty "Registry::HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" `
        -name "IconSpacing" -value (-1030) -type string

    # Windows Subsysten Linuxの有効化
    # https://docs.microsoft.com/ja-jp/windows/wsl/install-win10
    Write-Output("[INFO] enable windows subsystem linux")
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    Write-Output("[INFO] You need to reboot.")
}

### main
# debug
#Set-PSDebug -Trace 1

# 管理者権限チェック ref: https://qiita.com/skkzsh/items/5e03bb7792629927acfa
if (! ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need admin permission..."
    Read-Host "press enter to exit this script"
    exit 0
}

# 引数渡されたらその動作で
$acceptable_mode = "init|install|update|config"
if ($Args[0] -match "^($acceptable_mode)$") {
    $mode = $Args[0]
}
else {
    $mode = Read-Host "Input mode: {$acceptable_mode} "
}
switch ($mode) {
    "init" { install_choco }
    "install" { install_softwares_by_choco }
    "update" { update_softwares_by_choco }
    "config" { setup_configs_for_myself }
    default { Write-Warning "unexpected mode: $mode" }
}

# エラーとか出がちなので、勝手にウインドウを閉じないように
Read-Host "press enter to exit this script"
