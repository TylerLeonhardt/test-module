$ModuleManifestName = 'test-module.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Write-Host "In first test"
        Write-Host $pid
        while (-not (get-runspace -id 1).debugger.IsActive) {
            $p = $pid
            sleep 1
        };
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}
