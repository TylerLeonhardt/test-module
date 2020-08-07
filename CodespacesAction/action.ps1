#!/usr/bin/env pwsh

# Load the common function helper module for interacting
# with the GitHub Actions/Workflow environment
Import-Module -Name "$PSScriptRoot/lib/ActionsCore.psm1"
Import-Module -Name "$PSScriptRoot/lib/Codespaces.psm1"

# replace with parameter/configuration when available
$Plan = Get-ActionInput Plan
$Subscription = Get-ActionInput Subscription
$ArmToken = Get-ActionInput ArmToken

Start-Codespaces -Subscription $Subscription -Plan $Plan -ArmToken $ArmToken

# sh ./CodespacesAction/install-vso.sh
# $env:VSCS_ARM_TOKEN=$ArmToken

# $a = ls
# $b = pwd
# $c = ls ./bin/codespaces
# $d = ls ./CodespacesAction 
# Write-ActionInfo "################################################"
# Write-ActionInfo "$a"
# Write-ActionInfo "################################################"
# Write-ActionInfo "$b"
# Write-ActionInfo "################################################"
# Write-ActionInfo "$c"
# Write-ActionInfo "################################################"
# Write-ActionInfo "$d"

# "n`n1`n`n" | ./bin/codespaces start -s $Subscription -p $Plan

# $id = $pid
# Write-ActionInfo "pid is $id"

# Set-ActionOutput -Name 'logPath' -Value "some path"
# Set-ActionOutput -Name 'result' -Value 'passed'