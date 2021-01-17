# Remove Azure Resources including those in Azure Active Directory (Azure AD).

param (
    [Parameter(Mandatory)] $EnvironmentName
)

$ErrorActionPreference = "Stop"

Write-Host "`nRemoving Azure Resources for environment name: '$EnvironmentName'"

#=================================================================================
# Load variables.
$scriptVariablesFilePath = "./Environments/$EnvironmentName.ScriptVariables.json"
Write-Host "Loading Variables from file: $scriptVariablesFilePath"
$variables = (Get-Content $scriptVariablesFilePath -Raw) | ConvertFrom-Json -AsHashtable

# ===========================================================================================
# Remove Azure resources by removing the containing Azure Resource Group.
#

$resourceGroup = Get-AzResourceGroup -Name $variables['resourceGroupName'] -ErrorAction SilentlyContinue
if ($resourceGroup)
{
    Write-Host "Removing Resource group '$($variables['resourceGroupName'])'."

    # Remove Resource Group without confirmation.
    # https://docs.microsoft.com/en-us/powershell/module/az.resources/remove-azresourcegroup
    Remove-AzResourceGroup -Name $variables['resourceGroupName'] -Force
}
else {
    Write-Host "Resource group '$($variables['resourceGroupName'])' does not exist."
}

Write-Host "`nDone.`n";
