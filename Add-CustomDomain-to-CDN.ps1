# Add the given environment's custom domain for the static website to the Azure CDN endpoint.
# And enable HTTPS on the Azure CDN endpoint using a CDN-managed certificate.
#
# Microsoft Docs: Host a static website in Azure Storage
# https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-powershell

param (
    [Parameter(Mandatory)] $EnvironmentName
)

$ErrorActionPreference = "Stop"

Write-Host "`nAdd custom domain to Azure CDN Enpoint for the static website.`n"

#=================================================================================
# Load variables.
$scriptVariablesFilePath = "./Environments/$EnvironmentName.ScriptVariables.json"
Write-Host "Loading Variables from file: $scriptVariablesFilePath"
$variables = (Get-Content $scriptVariablesFilePath -Raw) | ConvertFrom-Json -AsHashtable

# ===========================================================================================
Write-Host "Starting to add custom domain to Azure CDN Endpoint."

# -------------------------------------------------------------------------------------------
Write-Host "Getting the existing Azure CDN Endpoint."
#
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/get-azcdnendpoint?view=azps-5.2.0

$endpoint = Get-AzCdnEndpoint `
    -ProfileName $variables['cdnProfileName'] `
    -ResourceGroupName $variables['resourceGroupName'] `
    -EndpointName $variables['cdnEndpointName']

# -------------------------------------------------------------------------------------------
Write-Host "Checking if the custom domain can be added to the endpoint."
#
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/test-azcdncustomdomain?view=azps-5.2.0

$result = Test-AzCdnCustomDomain `
    -CdnEndpoint $endpoint `
    -CustomDomainHostName $variables['cdnCustomDomainHostName']

# Generate the customDomainDisplayName (display name)
# We generate the customDomainDisplayName from the Custom Domain host name by replacing periods with with hyphens.
# The customDomainDisplayName is used to set the internal Name property of the Custom Domain object in Azure.
$customDomainDisplayName = $variables['cdnCustomDomainHostName'].Replace('.', '-')
Write-Host "customDomainDisplayName: '$customDomainDisplayName'"

# -------------------------------------------------------------------------------------------
Write-Host "Creating the custom domain on the CDN endpoint."
# 
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/new-azcdncustomdomain?view=azps-5.2.0
If ($result.CustomDomainValidated) {

    $customDomain = New-AzCdnCustomDomain `
        -CustomDomainName $customDomainDisplayName `
        -HostName $variables['cdnCustomDomainHostName'] `
        -CdnEndpoint $endpoint

    Write-Host "`n$($customDomain | ConvertTo-Json)`n"

} else {
    Write-Host "Custom domain could NOT be added to the endpoint." -ForegroundColor "Red"
    Write-Host "  cdnEndpointName: $($variables['cdnEndpointName'])" -ForegroundColor "Red"
    Write-Host "  cdnEndpoint HostName: $($endpoint.HostName)" -ForegroundColor "Red"
    Write-Host "  cdnCustomDomainHostName: $($variables['cdnCustomDomainHostName'])" -ForegroundColor "Red"

    Write-Host "`n$($result | ConvertTo-Json)`n" -ForegroundColor "Red"
}

# ===========================================================================================
Write-Host "Enabling HTTPS on the CDN custom domain with a CDN-managed certificate."
# https://docs.microsoft.com/en-us/powershell/module/az.cdn/enable-azcdncustomdomainhttps

Enable-AzCdnCustomDomainHttps `
    -ResourceGroupName $variables['resourceGroupName'] `
    -ProfileName $variables['cdnProfileName'] `
    -EndpointName $variables['cdnEndpointName'] `
    -CustomDomainName $customDomainDisplayName

# ===========================================================================================
# Display Information

Write-Host "`nIMPORTANT!" -ForegroundColor "Blue"
Write-Host "Record the information displayed belew in Blue (the same color as this text)." -ForegroundColor "Blue"

Write-Host "`nStorage URL: $($storageAccount.PrimaryEndpoints.Web)" -ForegroundColor "Blue"

Write-Host "`nCDN Endpoint URL: https://$($endpoint.HostName)" -ForegroundColor "Blue"

Write-Host "`nCustom Domain URL: https://$($variables['cdnCustomDomainHostName'])" -ForegroundColor "Blue"

Write-Host "`nIMPORTANT!" -ForegroundColor "Blue"
Write-Host "Record the information displayed above in Blue (the same color as this text)." -ForegroundColor "Blue"

Write-Host "`nDone.`n"
