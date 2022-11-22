<#
.SYNOPSIS
    Scans a given directory and list the size of child objects
.DESCRIPTION
	Scans a given directory and list the size of child objects
.EXAMPLE
    .\Get-DirectorySize.ps1 -ScanDir C:\temp -Recursive true
.EXAMPLE
    .\Get-DirectorySize.ps1 -ScanDir C:\temp -Recursive false -SortbyPath true -CSVExportPath C:\export\export.csv
.EXAMPLE
    .\Get-DirectorySize.ps1 -ScanDir C:\temp -Recursive true -CSVExportPath C:\export\recursive-export.csv
.PARAMETER ScanDir
    The directory to scan. Do not include "
.PARAMETER Recursive
    Should the scan be recursive. either true or false
.PARAMETER SortbyPath
   Sorts the result by filepath, if not filled, size in MB is used
.PARAMETER CSVExportPath
    If filled, the results will be exported to a CSV file. This path should include the CSV name, ex Export.csv
#>

#region script parameters
[CmdletBinding(SupportsShouldProcess=$True)]
Param
(
    [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$false,
        HelpMessage="Directory to scan"
    )]
    [ValidateNotNullorEmpty()]
    [String]
    $ScanDir,
    
    [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$false,
        HelpMessage="Should the scan be recursive. either true or false"
    )]
    [ValidateNotNullorEmpty()]
    [String]
    $Recursive,

    [Parameter(
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$false,
        HelpMessage="Sorts the result by filepath, if not filled, size in MB is used"
    )]
    [String]
    $SortbyPath,

    [Parameter(
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$false,
        HelpMessage="If filled, the results will be exported to a CSV file. This path should include the CSV name"
    )]
    [String]
    $CSVExportPath
#>

)
#endregion script parameters

$verbosepreference = "continue"

$startFolder = $ScanDir

$OutputCollection=  @()


if ($Recursive -eq "true") {
    $colItems = (Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
}
else {
    $colItems = (Get-ChildItem $startFolder | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
}


foreach ($i in $colItems)
    
    {

        #Write-Host Get-ChildItem $i.FullName
        $subFolderItems = (Get-ChildItem $i.FullName | Where-Object { -not $_.PSIsContainer } | Measure-Object -property length -sum)
        $size = ($subFolderItems.sum / 1MB)
        $sizeRounded = [System.Math]::Round($size, 2)
        
          $output = New-Object -TypeName PSobject 
          $output | add-member NoteProperty "SizeMB" -value $sizeRounded
          $output | add-member NoteProperty "Directory" -value $i.FullName
          $OutputCollection += $output
         
           
    }


if ($SortbyPath.ToLower() -eq "true"){
    $OutputCollection | Sort-Object Directory -Descending | Format-Table
} else {
    $OutputCollection | Sort-Object SizeMB -Descending | Format-Table
}



if ($CSVExportPath) {
    $OutputCollection | Export-Csv $CSVExportPath -NoTypeInformation
    Write-Host Exported results to $CSVExportPath
}
