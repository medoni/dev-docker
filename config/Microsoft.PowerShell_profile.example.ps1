Import-Module DirColors

Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-Variable -Name MaximumHistoryCount 32767

$curDir = Split-Path $MyInvocation.MyCommand.Path -Parent

function global:prompt { 
    Write-Host "";
    Write-Host "$(get-location -psprovider filesystem)"; 
    Write-Host "$([char]0x03BB)" -NoNewline -ForegroundColor green; 
    return " ";
}
cd /mnt/c/Users/JDoe/projects/

# environments
$env:PATH += ":/usr/games"
$env:PATH += ":/root/go/bin/"

$env:C_VOLUME_PATH = "/mnt/c"
$env:projects_VOLUME_PATH = "/mnt/c/Users/XXXX/projects/"

# basic aliases
function la() { dir $args }
function bat() { batcat $args }

# git aliases
function gl()   { git log --decorate=auto --oneline --graph $args }
function glfp() { git log --decorate=auto --oneline --graph $args --first-parent $args }
function gs()   { git status $args }
function go()   { git checkout $args }
function gb()   { git branch $args }
function gc()   { git commit -a -m $args }
function gca()  { git commit --amend $args }
function ga()   { git add $args }
function ga()   { git add . $args }
function gd()   { git diff $args }
function gcp()  { git cherry-pick  $args }

# docker aliases
function d() { docker $args}
function dc() { docker compose $args}

# windows commands
function subl($file) { & '/mnt/c/Program Files/Sublime Text/subl.exe' $(wslpath -w $file) }
function cmd() { /mnt/c/Windows/System32/cmd.exe $args } 
function start($file) { cmd /c start $(wslpath -w $file) }