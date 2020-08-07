function Start-Codespaces {
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$Subscription,
        [Parameter(Position=1, Mandatory)]
        [string]$Plan,
        [Parameter(Position=2, Mandatory)]
        [string]$ArmToken
    )
    sh (Join-Path $PSScriptRoot install-vso.sh)
    $env:VSCS_ARM_TOKEN=$ArmToken

    "n`n1`n`n" | ./bin/codespaces start -s $Subscription -p $Plan

    Write-Output "Done"
}