while (-not (get-runspace -id 1).debugger.IsActive) {
    $p = $pid
    sleep 1
};

$p = $pid
Write-Host $p
$a = 0
Write-Host $a
$a = $a + 1
$a = $a - 2
Write-Host $a