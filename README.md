### What is the PSADT Module

This is a fork of [PowerShell App Deployment Toolkit](https://github.com/PSAppDeployToolkit/PSAppDeployToolkit) and it was modified so it can be installed as a PowerShell module.

In order for the [PowerShell App Deployment Toolkit](https://github.com/PSAppDeployToolkit/PSAppDeployToolkit) PowerShell module to load automatically when PowerShell is launched, you can copy the following code to the system [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7) file located in _**C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1**_.

```powershell
# PowerShell Wrapper for MDT, Standalone and Chocolatey Installation - (C)2020 Jonathan Pitre, inspired by xenappblog.com
# Example 1 Install EXE:
# Execute-Process -Path .\appName.exe -Parameters "/silent"
# Example 2 Install MSI:
# Execute-MSI -Action Install -Path appName.msi -Parameters "/QB" -AddParameters "ALLUSERS=1"
# Example 3 Uninstall MSI:
# Remove-MSIApplications -Name "appName" -Parameters "/QB"

# Custom package providers list
$PackageProviders = @("Nuget")

# Custom modules list
$Modules = @("PSADT")

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Checking for elevated permissions...
If (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning -Message "Insufficient permissions to continue! PowerShell must be run with admin rights."
    Break
}
Else {
    Write-Verbose -Message "Importing custom modules..." -Verbose

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

    # Install custom package providers list
    Foreach ($PackageProvider in $PackageProviders) {
        If (-not(Get-PackageProvider -ListAvailable -Name $PackageProvider -ErrorAction SilentlyContinue)) {Install-PackageProvider -Name $PackageProvider -Force}
    }

    # Add the Powershell Gallery as trusted repository
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    # Update PowerShellGet
    $InstalledPSGetVersion = (Get-PackageProvider -Name PowerShellGet).Version
    $PSGetVersion = [version](Find-PackageProvider -Name PowerShellGet).Version
    If ($PSGetVersion -gt $InstalledPSGetVersion) {Install-PackageProvider -Name PowerShellGet -Force}

    # Install and import custom modules list
    Foreach ($Module in $Modules) {
        If (-not(Get-Module -ListAvailable -Name $Module)) {Install-Module -Name $Module -AllowClobber -Force | Import-Module -Name $Module -Force}
        Else {
            $InstalledModuleVersion = (Get-InstalledModule -Name $Module).Version
            $ModuleVersion = (Find-Module -Name $Module).Version
            $ModulePath = (Get-InstalledModule -Name $Module).InstalledLocation
            $ModulePath = (Get-Item -Path $ModulePath).Parent.FullName
            If ([version]$ModuleVersion -gt [version]$InstalledModuleVersion) {
                Update-Module -Name $Module -Force
                Remove-Item -Path $ModulePath\$InstalledModuleVersion -Force -Recurse
            }
        }
    }

    Write-Verbose -Message "Custom modules were successfully imported!" -Verbose
}
````

### Tips and Tricks

You can use the cmdlet **Show-HelpConsole** or the alias **Get-PSADTHelp** to launch the [PowerShell App Deployment Toolkit](https://github.com/PSAppDeployToolkit/PSAppDeployToolkit) help console.

All variables from **AppDeployToolMain.ps1** are available for use once a cmdlet is executed. They should cover all your needs to detect the system environment you're running your installation script from. Run the **Get-Variable** to see the full list.

### Examples

My intend for this module was to combine the power of [PowerShell App Deployment Toolkit](https://github.com/PSAppDeployToolkit/PSAppDeployToolkit) and the [Evergreen](https://github.com/aaronparker/Evergreen) module to create the perfect installation scripts for all your Windows applications. I will provide some examples in the future in this GitHub repo.
