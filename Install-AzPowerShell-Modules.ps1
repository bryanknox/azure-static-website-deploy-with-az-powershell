# Install Az PowerShell. (a.k.a. Azure PowerShell)
# From:
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps

$ErrorActionPreference = "Stop"

# Display the PowerShell Version currently installed.
# PowerShell 7.x and later is the recommended version of PowerShell for use with Azure PowerShell on all platforms.
#  Install the latest version of PowerShell available for your operating system.
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7
$PSVersionTable.PSVersion

# Using the PowerShellGet cmdlets is the preferred installation method.
# Install the Az module for the current user only. This is the recommended installation scope.
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps

if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
      'Az modules installed at the same time is not supported.')
} else {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}
