[CmdletBinding()]
param(
    # Computer name to connect to
    [string]$File = '~/todo.csv'
)

# ToDo Item
class Item {
    # Internal Identifier
    [int]$Id
    # Item Title
    [string]$Title
    # Item Description
    [string]$Description
    # Due date
    [datetime]$DueDate
    # Item Status
    [string]$Status = 'ToDo'
    # Icon
    [string]$Icon

    SetIcon() {
        switch ($this.Status) {
            'ToDo' {
                $this.Icon = '⬛'
            }
            'Done' {
                $this.Icon = '✔️'
            }
            Default {
                $this.Icon = '❔'
            }
        }
    }
}

<# Script variables #>
# ToDo Items
[Item[]]$script:Items = @()
# Modified since last save
[bool]$script:Modified = $false

<# Helper functions #>
function Get-Decision {
    [string]$Decision = Read-Host "Press a key to continue to menu (or 'q' to quit program)"
    if ( $Decision -ieq 'q' ) {
        Exit 0
    }
}

# Read Items from file
function Read-Items {
    if ( Test-Path $File ) {
        # Import existing file
        $script:Items = Import-Csv -Path $File
        $script:Modified = $false
    } else {
        # No to items yet
        Write-Warning "Items file does not exit yet: $File"
    }
}

# Save Items to file
function Save-Items {
    $script:Items | ConvertTo-Csv | Out-File -FilePath $File
    $script:Modified = $false
}

# Add Item to list
function Add-Item {
    [Item]$Item = [Item]::new()
    $Item.Id = $script:Items.Count + 1
    Write-Host "Adding new Item with Id: $($Item.Id)"
    $Item.Title = Read-Host ' - Title?'
    $Item.Description = Read-Host ' - Description?'
    # ToDo: handle dates
    # [string]$DueDate = Read-Host ' - Due Date (yyyy-MM-dd)?'
    # $Item.$DueDate
    $Item.SetIcon()
    $script:Items += $Item
    $script:Modified = $true
    Write-Information 'Item added.'
}

# List Items
function Get-Items {
    $script:Items | Format-Table -Autosize | Out-Host
    Get-Decision
}

# Select One item in list & get confirmation
function Select-One {
    $script:Items | Format-Table -Autosize | Out-Host
    [int]$Id = Read-Host 'ID of Item to select (-1 to cancel)?'
    [Item]$Item = $script:Items | Where-Object -Property Id -eq $Id
    if ( $null -eq $Item ) {
        Write-Debug "Item not found with Id: $Id"
    } else {
        $Item | Format-Table -AutoSize | Out-Host
        [string]$Action = Read-Host "Confirm selection of item $Id [Y/y]?"
        if ( $Action -ieq 'y' ) {
            return $Item
        }
    }
}

# Update an item
function Update-Item {
    [Item]$Item = Select-One
    if ( $null -eq $Item ) {
        Write-Debug 'No item to update'
    } else {
        Write-Host "Updating Item with Id: $($Item.Id)"
        # Todo: Try with default values ?
        # See: https://stackoverflow.com/questions/26386267/is-there-a-one-liner-for-using-default-values-with-read-host
        $Item.Title = Read-Host " - Title: $($Item.Title)?"
        $Item.Description = Read-Host " - Description: $($Item.Description)?"
        # ToDo: handle dates
        $Item.Status = Read-Host " - Status: $($Item.Status)?"
        $Item.SetIcon()
        # ToDo:
        # Is the object updated directly? Removed from list then added again.
        $script:Items = $script:Items | Where-Object -Property Id -ne $Item.Id
        $script:Items += $Item
        Write-Information "Item Id $($Item.Id)) has been updated: $($Item.Title)"
        Start-Sleep -Second 1
        $script:Modified = $true
    }
}

# Remove Item
function Remove-Item {
    [Item]$Item = Select-One
    if ( $null -eq $Item ) {
        Write-Debug 'No item to remove'
    } else {
        $script:Items = $script:Items | Where-Object -Property Id -ne $Item.Id
        Write-Information "Item Id $($Item.Id)) has been removed: $($Item.Title)"
        Start-Sleep -Second 1
        $script:Modified = $true
    }
}

# Exit Program
function Show-Out {
    if ( $script:Modified ) {
        Write-Host 'It appears that the ToDo list has been modified since the last save'
        [string]$Save = Read-Host 'Press Y/y to save the list before exiting'
        if ( $Save -ieq 'y' ) {
            Save-Items
        }
    }
    Exit 0
}

# Main Function
function Run {
    if ( $null -eq $Items -or $Items.Count -eq 0) {
        Write-Information 'Loading items from file'
        Read-Items
    }
    [int]$Option = 1
    while ( $Option -gt 0) {
        Clear-Host
        Write-Host ''
        Write-Host '-= Stats =-'
        Write-Host " > Total number of items: $($Items.Count) "
        Write-Host ''
        Write-Host '-= Menu =-'
        Write-Host ''
        Write-Host "1) Reload list from file ($File)"
        Write-Host '2) List items'
        Write-Host '3) Add item'
        Write-Host '4) Update Item'
        Write-Host '5) Delete Item'
        Write-Host '6) Save Items'
        Write-Host ''
        Write-Host '9) Save & Quit'
        Write-Host '0) Quit'
        Write-Host ''
        $Option = Read-Host 'Your choice?'
        Write-Host ''
        switch ($Option) {
            0 {
                # Quit
                Show-Out
            }
            1 {
                # Read from file
                Read-Items
            }
            2 {
                # List items
                Get-Items
            }
            3 {
                # Add Item
                Add-Item
            }
            4 {
               # Update Item
               Update-Item
            }
            5 {
                # Delete Item
                Remove-Item
            }
            6 {
                # Save Item
                Save-Items
            }
            9 {
                # Save & Quit
                Save-Items
                Show-Out
            }
            Default {
                Write-Warning 'Unknown option selected'
            }
        }
    }
}

Run