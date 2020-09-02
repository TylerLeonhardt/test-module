$script:tempDir = [System.IO.Path]::GetTempPath()
$script:codespacesLoc = [System.IO.Path]::Combine($script:tempDir, "codespaces", "bin", "codespaces")
$script:agentVersion = "3997869"

function Start-Codespaces {
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$Subscription,
        [Parameter(Position=1, Mandatory)]
        [string]$ResourceGroup,
        [Parameter(Position=2, Mandatory)]
        [string]$Plan,
        [Parameter(Position=3, Mandatory)]
        [string]$ArmToken,
        [Parameter(Position=4)]
        [string]$SessionName,
        [switch]$Wait
    )

    Write-Host "$(Get-TimeStamp) Stop any active Codespaces instances"
    Stop-Codespaces $ArmToken

    Install-Codespaces $script:tempDir

    $env:VSCS_ARM_TOKEN=$ArmToken

    Write-Host "$(Get-TimeStamp) Starting codespaces session"
    $curDir = Get-Location
    $csJob = Start-Job -ScriptBlock {
        Set-Location $using:curDir
        $codespacesExec = $using:codespacesLoc
        $subscription = $using:Subscription
        $plan = $using:Plan
        $resourceGroup = $using:ResourceGroup
        $sessionName = $using:SessionName
        ("n`n" + $sessionName + "`n") | & $script:codespacesExec start -s $subscription -p $plan -r $resourceGroup
    }

    while ($true) {
        $output = Receive-Job $csJob
        if($output.length -gt 0){
            if($output -match '\[!ERROR\]'){
                Write-Host $output
                return;
            }
            Write-Host $output
            if($output -match 'online.visualstudio.com'){
                $url = $output.substring($output.IndexOf("https"))
                break;
            }
        }
    }

    if ($Wait) {
        Write-Host "$(Get-TimeStamp) Waiting for debugger to attach"
        while (-not $host.Runspace.debugger.IsActive) {
            Write-Host "$(Get-TimeStamp) pid: $pid, Connect: $url"
            Start-Sleep 3
        };
    }
    else {
        Write-Host "$(Get-TimeStamp) pid: $pid, Connect: $url"
    }
}

function Stop-Codespaces{
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$ArmToken
    )
    $env:VSCS_ARM_TOKEN=$ArmToken
    $codespacesBin = [System.IO.Path]::Combine($script:tempDir, "codespaces", "bin")
    if(Test-Path $codespacesBin){
        $output = & $script:codespacesLoc stop
        if($output -match "!ERROR"){
            Write-Host "$(Get-TimeStamp) No active Codespaces session found"
        }
        else{
            Write-Host "$(Get-TimeStamp) Removed previously active Codespaces session."
        }
    }

    if ($null -ne (Get-Process -Name "vsls-agent" -ea "SilentlyContinue")){
        Write-Host "$(Get-TimeStamp) Ending vsls-agent that was still active from a previous session"
        $id = (Get-Process -Name "vsls-agent").Id
        Stop-Process -Id $id
        if(Get-Process -Id $id){
            Wait-Process -Id $id
        }
        Start-Sleep 3
    }
}

function Install-Codespaces{
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$BinParentDir
    )

    $global:ProgressPreference = "SilentlyContinue"
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"
    $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

    if(Test-Path (Join-Path $BinParentDir "codespaces")){
        Write-Host "$(Get-TimeStamp) Codespaces folder already exists at $BinParentDir. Deleting and reinstalling."
        Remove-Item (Join-Path $BinParentDir "codespaces") -force -recurse
    }

    New-Item -Path $BinParentDir -Name "codespaces" -ItemType "directory" | Out-Null
    New-Item -Path (Join-Path $BinParentDir "codespaces") -Name "bin" -ItemType "directory" | Out-Null

    $destination = [System.IO.Path]::Combine($BinParentDir, "codespaces", "bin")
    $webClient = New-Object System.Net.WebClient
    switch ($true) {
        ($PSVersionTable.PSVersion.Major -lt 6) {
            # Must be PowerShell Core on Windows
            Import-Module -Name "Microsoft.PowerShell.Archive"
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_win_$agentVersion.zip"
            $tempdestination = New-Item "codespaces.zip"
            Write-Host "$(Get-TimeStamp) Downloading zip file (Windows)"
            $WebClient.DownloadFile($source, $tempdestination)


            # TEMP FIX
            $tempdestination = "VSOAgent_win_3997490.zip"
            Write-Host "$(Get-TimeStamp) Extracting from zip file"
            Expand-Archive -Path $tempdestination -Destination $destination -Force
            break
        }
        $IsMacOS {
            $tempdestination = New-TemporaryFile
            Import-Module -Name "Microsoft.PowerShell.Archive"
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_osx_$agentVersion.zip";
            Write-Host "$(Get-TimeStamp) Downloading zip file (MacOS)"
            $WebClient.DownloadFile($source, $tempdestination)

            Write-Host "$(Get-TimeStamp) Extracting from zip file"
            Expand-Archive -Path $tempdestination -Destination $destination -Force
            chmod -R +x [System.IO.Path]::Combine($script:tempDir, "codespaces", "bin")
            break
        }
        $IsLinux {
            $tempdestination = New-TemporaryFile
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_linux_$agentVersion.tar.gz"
            Write-Host "$(Get-TimeStamp) Downloading tar.gz file (Linux)"
            $WebClient.DownloadFile($source, $tempdestination)

            Write-Host "$(Get-TimeStamp) Extracting from tar.gz file"
            tar -xf $tempdestination -C $destination
            break
        }
        Default {
            $tempdestination = New-TemporaryFile
            # Must be PowerShell Core on Windows
            Import-Module -Name "Microsoft.PowerShell.Archive"
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_win_$agentVersion.zip"

            Write-Host "$(Get-TimeStamp) Downloading zip file (Windows)"
            $WebClient.DownloadFile($source, $tempdestination)
            Write-Host "$(Get-TimeStamp) Extracting from zip file"

            Expand-Archive -Path $tempdestination -Destination $destination -Force
            break
        }
    }

    Remove-Item $tempdestination
    Write-Host "$(Get-TimeStamp) Done installing codespaces"
}

function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}
