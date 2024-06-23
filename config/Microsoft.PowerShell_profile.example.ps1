Import-Module DirColors
Import-Module posh-git
. /root/scripts/Completitions.ps1 

Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-Variable -Name MaximumHistoryCount 32767

function global:prompt { 
    Write-Host ""
    Write-Host "$(get-location -psprovider filesystem)" -ForegroundColor darkgreen
    Write-Host "$([char]0x03BB)" -NoNewline -ForegroundColor green
    return " "
}
cd /mnt/c/Users/XXXX/projects/

# environments
$env:PATH += ":/usr/games"
$env:PATH += ":/root/go/bin/"

$env:C_VOLUME_PATH = "/mnt/c"
$env:projects_VOLUME_PATH = "/mnt/c/Users/XXXX/projects/"

# basic aliases
function Make-Alias($alias, $target) {
    $fn = "function global:$($alias) { $($target) `$args }"
    Invoke-Expression $fn

    Proxy-Completition $alias $target
}
Make-Alias 'la' 'dir'

# git aliases
Remove-Alias -name gc,gl -f
Make-Alias 'gl'   'git log --decorate=auto --oneline --graph'
Make-Alias 'glfp' 'git log --decorate=auto --oneline --graph --first-parent'
Make-Alias 'gs'   'git status'
Make-Alias 'go'   'git checkout'
Make-Alias 'gb'   'git branch'
Make-Alias 'gbd'  'git for-each-ref --sort=committerdate refs/heads/ --format="%(committerdate:short) %(refname:short)"'
Make-Alias 'gc'   'git commit -a -m'
Make-Alias 'gca'  'git commit --amend'
Make-Alias 'ga'   'git add'
Make-Alias 'ga.'  'git add .'
Make-Alias 'gd'   'git diff'
Make-Alias 'gcp'  'git cherry-pick'

# docker aliases
Make-Alias "d" "docker"
Make-Alias "dc" "docker compose"

# windows commands
function code($file) { & '/mnt/c/Users/XXXX/scoop/apps/vscode/current/Code.exe' $(wslpath -w $file) }
function cmd() { /mnt/c/Windows/System32/cmd.exe $args } 
function start($file) { cmd /c start $(wslpath -w $file) }
