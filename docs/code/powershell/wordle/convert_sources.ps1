[CmdletBinding()]
param (
)

[string]$OutputFile = 'out.csv'
[string[]]$Words = @()

[System.IO.FileInfo[]]$DictionnaryFiles = Get-ChildItem './Word lists in csv'
foreach ($DictionnaryFile in $DictionnaryFiles) {
    Write-Debug "Reading file: $($DictionnaryFile.BaseName)"
    [string[]]$Lines = Get-Content $DictionnaryFile
    Write-Debug "Number of lines $($Lines.Count)"
    foreach ($Line in $Lines) {
        if( $Line.Trim().Length -eq 5 ) {
            if ( $Words -contains $Line.Trim() ){
                # Avoid duplicates
            } else {
                if ( $Line -like '*-*' -or $Line -like '*"*' ) {
                    # Ignore
                } else {
                    $Words += $Line.Trim()
                }
            }
        }
    }
}

Write-Debug "Total words: $($Words.Length)"
$Words | Out-File -FilePath $OutputFile