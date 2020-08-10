function Start-Codespaces {
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$Subscription,
        [Parameter(Position=1, Mandatory)]
        [string]$Plan,
        [Parameter(Position=2, Mandatory)]
        [string]$ArmToken,
        [switch]$NoWait

    )

    Install-Codespaces

    Write-Host "Setting arm token"
    $env:VSCS_ARM_TOKEN=$ArmToken

    Write-Host "Starting codespaces"

    $csJob = Start-Job -ScriptBlock {
        $subscription = $using:Subscription
        $plan = $using:Plan
        "n`n1`n`n" | ./bin/codespaces start -s $subscription -p $plan
        $env:VSCS_ARM_TOKEN=""
    }

    $output = ""
    while ($true) {
        $output = Receive-Job $csJob
        if($output.length -gt 0){
            if($output -match '\[!ERROR\]'){
                Write-Host $output
                return;
            }
            if($output -match 'online.visualstudio.com'){
                Write-Host $output
                break;
            }
        }
    }

    Write-Host "Exiting module"


    Write-Host $pid
    if (-not $NoWait) {
        while (-not (get-runspace -id 1).debugger.IsActive) {

            Write-Host $output
            sleep 3
        };
    }
}

function Install-Codespaces{
    $global:ProgressPreference = "SilentlyContinue"
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"
    $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

    New-Item -Path . -Name "bin" -ItemType "directory"

    $destination="./bin"
    $tempdestination = New-TemporaryFile
    $webClient = New-Object System.Net.WebClient
    switch ($true) {
        $IsMacOS {
            Import-Module -Name "Microsoft.PowerShell.Archive"
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_osx_3920504.zip";

            Write-Host "Downloading"
            $WebClient.DownloadFile($source, $tempdestination)
            Write-Host "Expanding"

            Expand-Archive -Path $tempdestination -Destination $destination -Force
            chmod -R +x ./bin
            break
        }
        $IsLinux {
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_linux_3929085.tar.gz"
            Write-Host "Downloading"
            $WebClient.DownloadFile($source, $tempdestination)
            Write-Host "Expanding"
            tar -xf $tempdestination -C $destination
            break
        }
        Default {
            # Must be PowerShell Core on Windows
            Import-Module -Name "Microsoft.PowerShell.Archive"
            $source = "https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_win_3934786.zip"

            Write-Host "Downloading"
            $WebClient.DownloadFile($source, $tempdestination)
            Write-Host "Expanding"

            Expand-Archive -Path $tempdestination -Destination $destination -Force
            break
        }
    }
    Remove-Item $tempdestination
    Write-Host "Done"
}
