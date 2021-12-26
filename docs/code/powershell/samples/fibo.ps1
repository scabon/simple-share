[CmdletBinding()]
param(
    # Number of Fibonacci iterations
    [int]$NbIterations = 0
)

<#
    Compute Fibonacci value for a given number of Iterations, or f(x)
    As long as NbIterations is not equal to zero, call self shifting N-1 & N-2 values
    At then end, return N-1 + N-2
#>
function fibo {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Number of Fibonacci iterations
        [int]$NbIterations,
        # N-1 Value
        [int]$N1,
        # N-2 Value
        [int]$N2
    )
    Write-Debug "NbIterations (remaining): $NbIterations, N: $( $N1 + $N2), N1: $N1, N2: $N2"
    if ( $NbIterations -eq 0 ) {
        Write-Host "Result: $( $N1 + $N2 )"
        return $N1 + $N2
    }
    return fibo `
        -NbIterations ($NbIterations - 1) `
        -N1 ( $N1 + $N2 ) `
        -N2 $N1
}

<#
    Initialize Fibonacci sequence, because f(0) = 0 and f(1) = 1
    Call recursive function if > 1
#>
function FiboIni {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Number of Fibonacci iterations
        [int]$NbIterations
    )
    if ( $NbIterations -eq 0) {
        return 0
    }
    if ( $NbIterations -eq 1 ) {
        return 1
    }
    fibo `
        -NbIterations ($NbIterations -2) `
        -N1 1 `
        -N2 0
}

FiboIni -NbIterations $NbIterations