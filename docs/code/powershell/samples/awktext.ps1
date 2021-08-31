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

<# Explanations
    Get-Content -Path 'awktext.txt'
    -> reads the file content as an array of strings (one for each line in the file)
    Each line is passed down the pipeline, so the rest of the command (at the right of the pipe) is called for each line
    Measure-Object -Sum { ($_ -Split '\s' )[1] }
    -> Sums over each call (for each line) the result of the following expression: ($_ -Split '\s' )[1]
    Now if we break it down:
        . $_ is the current value from the pipeline (so the current line from the file)
        . -Split take $_ (the current line), and returns an array of the values separated by '\s'
        . '\s' matches any whitespace character, so this should be more flexible on the file format
        . [1] takes the second value from the array returned by the split (ie the second column)
#>