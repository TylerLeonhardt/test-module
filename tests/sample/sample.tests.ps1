Describe "sample" {
    it "pass" {
        $sum = 1 + 1
        
        while (-not (get-runspace -id 1).debugger.IsActive) {sleep 1};
        $sum | Should -Be 2
    }
}
