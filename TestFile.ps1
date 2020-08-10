$id = $pid
Write-Host "pid is $id in TestFile"

while (-not (get-runspace -id 1).debugger.IsActive) {sleep 1};
$a = 0
for($i = 0; $i -lt 200; $i++){ 
    $a = $a + $i;
    Start-Sleep -s 1;
}
