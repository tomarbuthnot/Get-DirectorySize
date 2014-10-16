
#0.1

$verbosepreference = "continue"

$startFolder = "C:\"

$OutputCollection=  @()

$colItems = (Get-ChildItem $startFolder | Measure-Object -property length -sum)
"$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

$colItems = (Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
foreach ($i in $colItems)
    
    {
        $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
        $size = ($subFolderItems.sum / 1MB)
        $sizeRounded = [System.Math]::Round($size, 2)
        write-verbose "$sizeRounded MB $($i.FullName)"
        
          $output = New-Object -TypeName PSobject 
          $output | add-member NoteProperty "Directory" -value $i.FullName
          $output | add-member NoteProperty "SizeMB" -value $sizeRounded
          $OutputCollection += $output
    
    }


    # $OutputCollection | Sort-Object SizeMB -Descending| Select-Object -First 100