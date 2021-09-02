<#
    Inspired by Jim SALTER
    See: https://arstechnica.com/gadgets/2021/08/linux-bsd-command-line-101-using-awk-sed-and-grep-in-the-terminal
    This is an exercice to translate Jim's examples of bash commands to their powershell equivalent.
    This was done using PowerShell Core on an Ubuntu (WSL2) for easier comparison.
    Beware: some examples might be wrong and are probably non-optimal.
#>

<# GREP examples #>

# bash: netstat -anp | head -n5
# Translates to:
netstat -anp | Select-Object -First 5
# Note: Select-Object can be replaced by its alias: 'select'

# bash: netstat -anp | wc -l
# Translates to:
netstat -anp | Measure-Object -Word
# Note: Measure-Object can be replaced by its alias: 'measure'

# bash: netstat -anp | grep apache
# Translates to:
netstat -anp | Select-String apache

#bash: netstat -anp | head -n2 ; netstat -anp | grep apache
# Translates to:
netstat -anp | Select-Object -First 2 ; netstat -anp | Select-String apache

<# SED examples #>

# bash: echo "I love my dog, dogs are great!"
# Translates to:
Write-Output "I love my dog, dogs are great!"
# Note: Select-Object can be replaced by its alias: 'echo'

# bash: echo "I love my dog, dogs are great!" | sed 's/dog/snake/'
# By default, the -replace operator replaces all occurences
# The only way I found to replace only the first one is from here:
# https://www.reddit.com/r/PowerShell/comments/bs5tms/replace_only_first_occurrence_of_string/
# It will make the next one easier (replace all occurences), but this one trickier
# So it translates to:
"I love my dog, dogs are great!" -replace '(.*?)(dog)(.*)', '$1snake$3'

# bash: echo "I love my dog, dogs are great!" | sed 's/dog/snake/g'
# Translates to:
"I love my dog, dogs are great!" -replace 'dog', 'snake'

# bash: sudo netstat -anp | grep ::80
# Translates to:
sudo netstat -anp | Select-String ::80

# bash: sudo netstat -anp | grep ::80 | sed 's/.*LISTEN *//'
# Translates to:
(sudo netstat -anp | Select-String ::80) -replace '.*LISTEN *', ''

<# AWK examples #>

# bash: sudo netstat -anp | grep apache
# Translates to:
sudo netstat -anp | Select-String apache
# Note: Select-String can be replaced by its alias: 'select'

# bash: sudo netstat -anp | grep apache | awk '{print $4}'
# Translates to:
((sudo netstat -anp | Select-String apache -raw) -replace '\s+', ' ' -split ' ')[3]
# For reasons, the direct -split does not work (because of the whitespaces returned by the netstat command?)
# So we replace any number of white space characters with only one, then split the result with ' '
# This allows to retrieve the 4 th column (id #3 in the list of items)

# bash: sudo netstat -anp | grep apache | awk '{print $4, $7}
# Translates to:
$str = (sudo netstat -anp | Select-String apache -raw) -replace '\s+', ' ' -split ' ' ; $str[3] + " " + $str[6]
# Not a real one-liner, but well....

#TODO: not sure the examples above work with more than one line returned by netstat....

<#
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