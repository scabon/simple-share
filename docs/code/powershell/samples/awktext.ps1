<#
    Inspired by Jim SALTER
    See: https://arstechnica.com/gadgets/2021/08/linux-bsd-command-line-101-using-awk-sed-and-grep-in-the-terminal
    Sample content of the awktext.txt file:
    1 2 3
    4 5 6
    7 8 9
    The goal is to sum the second column of the file.
#>

# Tests as regular script (for debug)
[int]$Sum = 0
[string[]]$content = Get-Content -Path 'awktext.txt'
foreach ($c in $content) {
    [string]$item = $c.Split(' ')[1]
    $Sum += $item
}
Write-Host "Sum: $Sum"

# As a one-liner
Get-Content -Path 'awktext.txt' | Measure-Object -Sum { ($_ -Split '\s' )[1] }