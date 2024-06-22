function Proxy-Completition($alias, $proxyTo) {
    $completerScriptBlock = [ScriptBlock]{
        param($wordToComplete, $commandAst, $cursorPosition)

        $cmdLine = "$($commandAst.ToString()) $wordToComplete"

        $proxiedText = $proxyTo + $cmdLine.Substring($alias.Length)
        $proxiedCursorPosition = $cursorPosition + $proxyTo.Length - $alias.Length

        $res = [System.Management.Automation.CommandCompletion]::CompleteInput(
            $proxiedText, 
            $proxiedCursorPosition,
            $null
        ).CompletionMatches

        return $res
    }.GetNewClosure()
    Register-ArgumentCompleter -Native -CommandName $alias -ScriptBlock $completerScriptBlock
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# docker & docker compose completition
Import-Module DockerCompletion 

