$id = $pid
Write-ActionInfo "pid is $id"

while (-not (get-runspace -id 1).debugger.IsActive) {sleep 1};
$a = 0
for($i = 0; $i -lt 200; $i++){ 
    $a = $a + $i;
    Start-Sleep -s 1;
}
