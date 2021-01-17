# Get Static Website URL

param (
    [Parameter(Mandatory)] $EnvironmentName
)

$ErrorActionPreference = "Stop"

Write-Host "`nGet Static Website URL for environment name: '$EnvironmentName'"

#=================================================================================
# Load variables.
$scriptVariablesFilePath = "./Environments/$EnvironmentName.ScriptVariables.json"
Write-Host "Loading Variables from file: $scriptVariablesFilePath"
$variables = (Get-Content $scriptVariablesFilePath -Raw) | ConvertFrom-Json -AsHashtable

#=================================================================================
# Docs: Get-AzStorageAccount
# https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageaccount?view=azps-4.8.0

$storageAccount = Get-AzStorageAccount `
  -ResourceGroupName $variables['resourceGroupName'] `
  -Name $variables['websiteStorageAccountName']
  
Write-Host "`nStatic Website URL: $($storageAccount.PrimaryEndpoints.Web)" -ForegroundColor "Blue"

# The host name is the website's Primary Endpoint URL without the protocol ("https://") and
# trailing "/".
#
[uri]$url = $storageAccount.PrimaryEndpoints.Web

Write-Host "`nStatic Website Host Name: $($url.Authority)" -ForegroundColor "Blue"

Write-Host "`nDone.`n"
