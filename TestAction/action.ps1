$id = $pid
Write-Host "pid is $id in TestAction"

while (-not (get-runspace -id 1).debugger.IsActive) {sleep 1};
$a = 0

