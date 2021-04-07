# Azure Static Website Deploy with Az PowerShell

Az PowerShell scripts for provisioning and deploying static websites in Azure Storage with Azure CDN for a custom domain and HTTPS.

Azure CDN-Managed certificates are used for HTTPS

> Use PowerShell 7 and the scripts will work on Linux, MacOS, and Windows.

# Steps

## Setup Environment ScriptVariables Files
Add an `{environmentName}.ScriptVariables.json` file to the `./Environments/` folder for each environment that you need.

The PowerShell scripts take a `-EnvironmentName` parameter that indicates the 
`./Environments/{environmentName}.ScriptVariables.json` file to be used.

Those files allow you configure the variable values to be used for individual environments in an easy to maintain location.

See `./Environments/Environment-ScriptVariables-ReadMe.md` for detailed information about the content of those files.

> TIP: Create a new `{environmentName}.ScriptVariables.json` from a copy of the `sample.ScriptVariables.json` file.


## Install Az PowerShell Modules
If not already installed, install the Az PowerShell Module by using the following PowerShell command.

PowerShell:
```
./Install-AzPowerShell-Modules.ps1
```

## Sign in to Azure Subscription for the Environment
Log into the Azure Subscription 
in a specific environment by using the following PowerShell command.

PowerShell:
```
./Signin-to-Azure-Subscription.ps1 -EnvironmentName play5
```

## Provision Static Website and CDN for the Environment
Provision the static website's Azure Storage Account, Azure CDN Profile and Azure CDN Endpoint
in a specific environment by using the following PowerShell command.

PowerShell:
```
./Provision-Static-Website-and-CDN.ps1 -EnvironmentName play5
```

The script will output information that is needed to to set up the DNS for the static website's custom domain for the environment.

## Upload Static Website Content for the Environment
Upload the static website's content to Azure Storage
in a specific environment by using the following PowerShell command.

PowerShell:
```
./Upload-Files-to-Static-Website.ps1 -EnvironmentName play5
```

> NOTE: It may take a while before newly uploaded content is available on the CDN. It should be immediately available in Azure Storage.

## Test the Static Website in Azure Storage for the Environment
Browse to the "Storage URL" output by the provisioning or upload scripts to test that the static website is being serviced from Azure Storage.

## Add CNAME Records in DNS for the Environment
Create CNAME records in DNS at your DNS provider's website.

Use the information output by the `Provision-Static-Website-and-CDN.ps1` script.

Example CNAME record:
```
CNAME play5.mydomain.com static-website-endpoint-play5.azureedge.net  
```

For more details see:
https://docs.microsoft.com/en-us/azure/cdn/cdn-map-content-to-custom-domain?tabs=azure-dns#create-a-cname-dns-record

## Add Custom Domain and HTTPS for Environment
Add the custom domain to the Azure CDN Endpoint and enable HTTPS
in a specific environment by using the following PowerShell command.

PowerShell:
```
./Add-CustomDomain-to-CDN.ps1 -EnvironmentName play5
```

> NOTE: It can take up to 6-8 hours for the custom domain HTTPS feature to be activated."

## Test the Static Website in Azure CDN for the Environment
Browse to the "CDN Endpoint URL" output by the add custom domain script to test that the static website is being served from the Azure CDN.

# Cleaning up.

## Removing Azure Resources
Remove the Azure Resources
in a specific environment by using the following PowerShell command.

> See the notes below about removing CNAME records first.

> WARNING: The script removes the entire Azure Resource Group and all of the resources it contains.

PowerShell:
```
./Remove-Azure-Resources.ps1
```
#### Remove CNAME records before removing CDN endpoints
Before you can remove Azure CDN endpoints that are associated with a custom domain name, you must first remove the CNAME records from DNS associated with that endpoint.

See Microsoft Docs: [Prevent dangling DNS entries and avoid subdomain takeover](https://docs.microsoft.com/en-us/azure/security/fundamentals/subdomain-takeover)

## Uninstalling Az PowerShell Modules
Uninstall ALL versions of the Az PowerShell Modules
by using the following PowerShell command.

PowerShell:
```
./Uninstall-AzPowerShell-Modules.ps1
```

You can modify that PowerShell script to uninstall specific versions.


# Utility Scripts

## Get-Static-Website-URLs.ps1
Get the URLs for the static website
in a specific environment by using the following PowerShell command.

PowerShell:
```
./Get-Static-Website-URLs.ps1
```
