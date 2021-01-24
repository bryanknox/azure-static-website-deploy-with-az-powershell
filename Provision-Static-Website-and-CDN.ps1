# Provision static website in Azure Storage for the given environment name.
#
# Microsoft Docs: Host a static website in Azure Storage
# https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-powershell

param (
    [Parameter(Mandatory)] $EnvironmentName
)

$ErrorActionPreference = "Stop"

Write-Host "`nProvision static website in Azure Storage`n"

#=================================================================================
# Load variables.
$scriptVariablesFilePath = "./Environments/$EnvironmentName.ScriptVariables.json"
Write-Host "Loading Variables from file: $scriptVariablesFilePath"
$variables = (Get-Content $scriptVariablesFilePath -Raw) | ConvertFrom-Json -AsHashtable

# ===========================================================================================
Write-Host "Creating Azure Resource Group if it does not exist."
#
# Docs: Create a storage account
# https://docs.microsoft.com/en-us/powershell/module/az.resources/get-azresourcegroup

$resourceGroup = Get-AzResourceGroup `
  -Name $variables['resourceGroupName'] `
  -ErrorAction SilentlyContinue

if ($resourceGroup)
{
    Write-Host "Resource Group '$($variables['resourceGroupName'])' already exists.";
}
else {
    Write-Host "Creating Resource Group: '$($variables['resourceGroupName'])'";

    # Docs: Create Azure Resource Group
    # https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azresourcegroup

    New-AzResourceGroup `
      -Name $variables['resourceGroupName'] `
      -Location $variables['location']
}

# ===========================================================================================
Write-Host "Starting storage account provisioning"

# -------------------------------------------------------------------------------------------
Write-Host "Creating Azure Storage Account."
#
# Docs: Create a storage account
# https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-powershell
#
# Docs: New-AzStorageAccount
# https://docs.microsoft.com/en-us/powershell/module/az.storage/new-azstorageaccount

$storageAccount = New-AzStorageAccount `
  -ResourceGroupName $variables['resourceGroupName'] `
  -Name $variables['websiteStorageAccountName'] `
  -Location $variables['location'] `
  -SkuName $variables['websiteStorageAccountSkuName'] `
  -Kind StorageV2

# -------------------------------------------------------------------------------------------
Write-Host "Enabling static website hosting."
#
# Docs: Enable-AzStorageStaticWebsite
# https://docs.microsoft.com/en-us/powershell/module/az.storage/enable-azstoragestaticwebsite

Enable-AzStorageStaticWebsite `
  -Context $storageAccount.Context `
  -IndexDocument $variables['websiteIndexDoc'] `
  -ErrorDocument404Path $variables['websiteErrorDocument404Path']

# ===========================================================================================
Write-Host "Starting Azure CDN provisioning"

# -------------------------------------------------------------------------------------------
Write-Host "Checking CDN endpoint name avaiability."
#
# Docs: Get-AzCdnEndpointNameAvailability
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/get-azcdnendpointnameavailability?view=azps-4.8.0
$availability = Get-AzCdnEndpointNameAvailability `
  -EndpointName $variables['cdnEndpointName']

If ($availability.NameAvailable) {
    Write-Host "CDN Endpoint Name is available: $($variables['cdnEndpointName'])"
}
Else {
    throw "CDN Endpoint Name is NOT available: $($variables['cdnEndpointName'])"
}

# -------------------------------------------------------------------------------------------
Write-Host "Creating CDN Profile"
#
# Docs: New-AzCdnProfile
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/new-azcdnprofile?view=azps-4.8.0

New-AzCdnProfile `
  -ProfileName $variables['cdnProfileName'] `
  -ResourceGroupName $variables['resourceGroupName'] `
  -Sku $variables['cdnProfileSku'] `
  -Location "Global"

# -------------------------------------------------------------------------------------------
Write-Host "Getting static website's host name"
# 
# The host name is the website's Primary Endpoint URL without the protocol ("https://") and
# trailing "/".
#
# Docs: Get-AzStorageAccount
# https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageaccount?view=azps-4.8.0

[uri]$staticWebsiteUrl = $storageAccount.PrimaryEndpoints.Web

$staticWebsiteHostName = $staticWebsiteUrl.Authority

# -------------------------------------------------------------------------------------------
Write-Host "Creating CDN endpoint"
#
# Docs: New-AzCdnEndpoint
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/new-azcdnendpoint?view=azps-4.8.0
#
# - We set the -OriginName to host name of the static website, but with hyphens instead of periods.
# The -OriginName is used to set the internal Name property of the endpoint's
# Microsoft.Azure.Commands.Cdn.Models.Endpoint.PSDeepCreatedOrigin object.
#
# - The OriginHostHeader must match the OriginHostName.
#   - If the OriginHeader is not set you'll bet a 400 error with "ErrorCode: InvalidUri" when you
#     try to GET the endpoint in a browser.
# - The port numbers must be explicitly set.

$originName = $staticWebsiteHostName.Replace('.', '-')
Write-Host "originName: '$originName'"

$endpoint = New-AzCdnEndpoint `
  -ProfileName $variables['cdnProfileName'] `
  -ResourceGroupName $variables['resourceGroupName'] `
  -Location "Global" `
  -EndpointName $variables['cdnEndpointName'] `
  -OriginHostName $staticWebsiteHostName `
  -OriginName $originName `
  -OriginHostHeader $staticWebsiteHostName `
  -HttpPort 80 `
  -HttpsPort 443

# ===========================================================================================
# Display Information

Write-Host "`nIMPORTANT!" -ForegroundColor "Blue"
Write-Host "Record the information displayed belew in Blue (the same color as this text)." -ForegroundColor "Blue"

Write-Host "`nStorage URL: $($storageAccount.PrimaryEndpoints.Web)" -ForegroundColor "Blue"

Write-Host "`nCDN Endpoint URL: https://$($endpoint.HostName)" -ForegroundColor "Blue"

Write-Host "`nInfo for use in DNS CNAME record:" -ForegroundColor "Blue"
Write-Host "Name: $($variables['cdnCustomDomainHostName'])" -ForegroundColor "Blue"
Write-Host "Content: $($endpoint.HostName)" -ForegroundColor "Blue"
Write-Host "Example:" -ForegroundColor "Blue"
Write-Host "CNAME $($variables['cdnCustomDomainHostName']) $($endpoint.HostName)" -ForegroundColor "Blue"
Write-Host
Write-Host "Name: cdnverify.$($variables['cdnCustomDomainHostName'])" -ForegroundColor "Blue"
Write-Host "Content: cdnverify.$($endpoint.HostName)" -ForegroundColor "Blue"
Write-Host "Example:" -ForegroundColor "Blue"
Write-Host "CNAME cdnverify.$($variables['cdnCustomDomainHostName']) cdnverify.$($endpoint.HostName)" -ForegroundColor "Blue"

Write-Host "`nIMPORTANT!" -ForegroundColor "Blue"
Write-Host "Record the information displayed above in Blue (the same color as this text)." -ForegroundColor "Blue"

Write-Host "`nDone.`n"
