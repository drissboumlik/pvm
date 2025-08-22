
# PHP Version Manager (PVM) - A PowerShell script to manage multiple PHP versions on Windows.

param($operation)


$ProgressPreference = 'SilentlyContinue'

# Load helper functions
. $PSScriptRoot\helpers\helpers.ps1

# Load configuration
Get-ChildItem "$PSScriptRoot\core\*.ps1" | ForEach-Object { . $_.FullName }

# Load actions scripts
Get-ChildItem "$PSScriptRoot\actions\*.ps1" | ForEach-Object { . $_.FullName }


if ($args -contains '--version' -or $args -contains '-v' -or $operation -eq 'version') {
    Write-Host "`nPVM version $PVM_VERSION"
    exit 0
}

$actions = Get-Actions -arguments $args

if (-not ($operation -and $actions.Contains($operation))) {
    Show-Usage
    exit 0
}

try {
    if ($operation -ne "setup" -and (-not (Is-PVM-Setup))) {
        Write-Host "`nPVM is not setup. Please run 'pvm setup' first."
        exit 1
    }

    $exitCode = $($actions[$operation].action.Invoke())
    exit $exitCode
} catch {
    $logged = Log-Data -data @{
        header = "$($MyInvocation.MyCommand.Name): An error occurred during operation '$operation'"
        file = $($_.InvocationInfo.ScriptName)
        line = $($_.InvocationInfo.ScriptLineNumber)
        message = $_.Exception.Message
        positionMessage = $_.InvocationInfo.PositionMessage
    }
    Write-Host "`nOperation canceled or failed to elevate privileges." -ForegroundColor DarkYellow
    exit 1
}