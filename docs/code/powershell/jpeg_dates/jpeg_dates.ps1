<#
    .SYNOPSIS
    Get all JPEG files from a folder, and change the file's last modification date to the 'date taken' from the picture.
#>
[CmdletBinding()]
param(
    # Path to folder containing JPEG files
    [string]$Folder = 'C:\Users\derze\Downloads'
)

# Set date taken property
function Set-DateTaken {
    [OutputType([datetime])]
    param(
        [System.IO.FileInfo]$Photo
    )
    [reflection.assembly]::LoadWithPartialName("System.Drawing")
    $pic = New-Object System.Drawing.Bitmap( $Photo.FullName )
    if ( $null -eq $pic) {
        return
    }
    try {
        $bitearr = $pic.GetPropertyItem(36867).Value
    }
    catch {
        return
    }
    if ( $null -eq $bitearr ) {
        return
    }
    $string = [System.Text.Encoding]::ASCII.GetString( $bitearr )
    [datetime]$dateTaken = [datetime]::ParseExact( $string,"yyyy:MM:dd HH:mm:ss`0", $Null )
    Write-Debug "Date taken: $dateTaken"
    $Photo.LastWriteTime = $dateTaken
}

# Files to process
[System.IO.FileInfo[]]$Photos = Get-ChildItem -Path $Folder -Recurse -File | Where-Object -Property Extension -in '.jpg', '.jpeg'
Write-Host "Number of photos found in $($Folder): $($Photos.Count)"

# Update the modified date for each file
foreach ($Photo in $Photos) {
    Write-Debug "Current photo: $($Photo.FullName)"
    Set-DateTaken -Photo $Photo
}
