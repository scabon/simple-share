[CmdletBinding()]
param (
)

[string[]]$Words = Get-Content 'out.csv'

[int]$nbWords = $Words.Count
Write-Debug "Number of words $nbWords"
[int]$Id = Get-Random -Maximum $nbWords
Write-Debug "Random number: $Id"
[string]$DispWord = $Words[$Id]
Write-Debug "Random Word: $DispWord"

[string[]]$Word = $DispWord.ToCharArray()
Write-Debug "Word as list: $Word"

[int]$nbTries = 1
[int]$MaxTries = 6

Write-Host 'Legend:'
Write-Host ' ⬛ = not in word'
Write-Host ' 🟩 = correct letter, correct position'
Write-Host ' 🟨 = correct letter, wrong position'

[string[]]$LastAnswer = @('?', '?', '?', '?', '?')
[string[]]$Help = @('⬜ ', '⬜ ', '⬜ ', '⬜ ', '⬜ ')
$Answsers = @()

[bool]$Won = $false

while ( $nbTries -le $MaxTries ) {
    Write-Host "Try $nbTries of $MaxTries"
    Write-Host "    $($LastAnswer -Join '  ')"
    Write-Host "    $($Help -Join ' ')"
    [string]$NewDispAnswer = Read-Host ':'
    if( $null -eq $NewDispAnswer ) {
        Write-Warning 'Please enter a word'
        continue
    }
    if( -Not ( $NewDispAnswer.Length -eq 5 ) ) {
        Write-Warning 'A five letter word is required'
        continue
    }
    if( -Not ( $Words -contains $NewDispAnswer ) ) {
        Write-Warning 'This word is not it the dictionnary'
        continue
    }
    [string[]]$Answer = $NewDispAnswer.ToCharArray()
    [int]$Position = 0
    [int]$ExactMacthes = 0
    $Help = @()
    foreach ($letter in $Answer) {
        if( $Word -contains $letter ) {
            Write-Debug "Letter $letter is in word $DispWord"
            if ( $Word[$Position] -ieq $letter ) {
                # Correct letter and position
                $Help += '🟩'
                $ExactMacthes++
            } else {
                # Correct letter wrong position
                $Help += '🟨'
            }
        } else {
            # Letter not in word
            $Help += '⬛'
        }
        $Position++
    }
    $Answsers += $Answer
    $LastAnswer = $Answer
    $nbTries++
    if( $ExactMacthes -eq 5 ) {
        $Won = $true
        break
    }
}

if( $Won ) {
    Write-Host 'You won, well done'
} else {
    Write-Host 'You loose, best luck next time'
    Write-Host "The answer was: $Word"
}