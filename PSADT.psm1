<#
    .SYNOPSIS
        PSADT script to initiate the module
#>

Get-ChildItem -Path "$PSScriptRoot" -Filter *.ps1 -Exclude 'AppDeployToolkitExtensions.ps1', 'AppDeployToolkitHelp.ps1' -Recurse | ForEach-Object { Export-ModuleMember $_.BaseName }
