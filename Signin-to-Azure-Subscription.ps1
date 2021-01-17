# Sign in to the Azure Subscription for the given environment name.
#

param (
    [Parameter(Mandatory)] $EnvironmentName
)

$ErrorActionPreference = "Stop"

Write-Host "`nSign in to Azure (Az) PowerShell for environment name: '$EnvironmentName'"

#=================================================================================
# Load variables.
$scriptVariablesFilePath = "./Environments/$EnvironmentName.ScriptVariables.json"
Write-Host "Loading Variables from file: $scriptVariablesFilePath"
$variables = (Get-Content $scriptVariablesFilePath -Raw) | ConvertFrom-Json -AsHashtable

#=================================================================================
# Sign in to Azure interactively with the Connect-AzAccount cmdlet. 
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount
# 
# In PowerShell 7, on any platform, you'll get a token to use
# on https://microsoft.com/devicelogin. 
#  1. Open the following page in your browser: https://microsoft.com/devicelogin
#  2. Enter the token output by the command.
#  3. Sign in with your Azure account credentials and authorize Azure PowerShell.
#
# In Windows PowerShell 5.1 environments a sign-in dialog will be displayed
# for you to enter a username and password for your Azure account. 

Write-Host "`Connecting to SubscriptionName: $($variables['subscriptionName'])`n"

Connect-AzAccount -SubscriptionName $variables['subscriptionName']

Write-Host "`nDone.`n"
