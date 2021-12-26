<#
    Compare execution times for two different kinds of iterations: terminal & non-terminal
    The functions return the sum of integers below Nb. For example:
    Sum( Nb = 10 ) => 0 + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 = 55
    Execution time is compared between the two methods for all values between 0 and Nb
#>

[CmdletBinding()]
param (
    [Parameter()]
    # Number to count sum for
    [int]$Nb
)

<#
    Terminal version of the sum (aka Tail Call)
    i.e. the result is always present in the Value parameter
#>
function SumTerminal {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Number to count sum for
        [int]$Nb,
        # Curent value
        [int]$Value
    )
    if ( $nb -le 0 ) {
        return $Value
    }
    return SumTerminal `
        -Nb ( $Nb - 1) `
        -Value ( $Value + $Nb )
}

<#
    Non Terminal version of the sum (Non a Tail Call)
    i.e. the result is not known until you add all the stack of calls return + return + ...
#>
function SumNonTerminal {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Number to count sum for
        [int]$Nb
    )
    if ( $nb -le 0 ) {
        return 0
    }
    return $Nb + (SumNonTerminal `
        -Nb ( $Nb - 1))
}

[System.Diagnostics.Stopwatch]$StopWatchTerminal = [System.Diagnostics.Stopwatch]::StartNew()
for ($i = 0; $i -le $Nb; $i++) {
    SumTerminal -Nb $Nb -Value 0 | Out-Null
}
$StopWatchTerminal.Stop()
Write-Debug "Execution time for Terminal version (ms): $($StopWatchTerminal.ElapsedMilliseconds)"

[System.Diagnostics.Stopwatch]$StopWatchNonTerminal = [System.Diagnostics.Stopwatch]::StartNew()
for ($i = 0; $i -le $Nb; $i++) {
    SumNonTerminal -Nb $Nb | Out-Null
}
$StopWatchNonTerminal.Stop()
Write-Debug "Execution time for Non Terminal version (ms): $($StopWatchNonTerminal.ElapsedMilliseconds)"

Write-Debug "Delta: $( $StopWatchNonTerminal.ElapsedMilliseconds - $StopWatchTerminal.ElapsedMilliseconds)"