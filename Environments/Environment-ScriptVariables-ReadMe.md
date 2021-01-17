
# Notes for {environmentName}.ScriptVariables.json Files

An `{environmentName}.ScriptVariables.json` file contains variable names and values
for a particular environment. Where the environment name corresponds to
the `{environmentName}` part of the file name.

A separate `{environmentName}.ScriptVariables.json` file should be created for each environment to
be provisioned, deployed to and maintained.

The `{environmentName}.ScriptVariables.json` file is read by PowerShell scripts.

The `{environmentName}` is the value passed to the `-EnvironmentName` parameter of those scripts.

Example
```
./my-script.ps1 -EnvironmentName "test4"
```

# Variables - General

## subscriptionName
The name of the existing Azure Subscription that the Azure resources will be associated with.

This should match the subscription name used when you sign in to Azure PowerShell using `Connect-AzAccount`.

Example:
```json
"subscriptionName": "Visual Studio Enterprise"
```

## location
The location (data center region) where all of the Azure resources should be located when they are created.

Example:
```json
"location": "West US"
```

## resourceGroupName
The name of the Azure Resource Group that will contain all of the Azure resources.

This resource group will be created if it does not already exist.

Example:
```json
"resourceGroupName": "static-website-play5-rg"
```

# Variables - Static Website Specific

## websiteStorageAccountName
The name of the Azure Storage account where the static website will be stored and hosted.

Example:
```json
"websiteStorageAccountName": "123456789012345678901234"
```

## websiteStorageAccountSkuName
The name of the Storage Account SKU used to provision the storage account.

Example:
```json
"websiteStorageAccountSkuName": "Standard_LRS"
```

## websiteIndexDoc
The name of the default document to be shown in each directory.

Example:
```json
"websiteIndexDoc": "index.html"
```

## websiteErrorDocument404Path
The the path to the document that should be shown when a browser requests a page that does not exist (404 not found).

Example:
```json
"websiteErrorDocument404Path": "error404.html"
```

## websiteUploadFolderPath
The path to the folder where the static website files to be uploaded are located.
All files in that folder are uploaded to the static website.

Example:
```json
"websiteUploadFolderPath": "./StaticWebSiteFiles"
```

# Variables - CDN for Static Website Specific

## cdnProfileName
The name of the Azure CDN Profile to be provisioned.

Example:
```json
"cdnProfileName": "static-website-profile-k0x-play5",
```

## cdnProfileSku
The name of the Azure CDN Profile SKU to be used when the CDN Profile is provisioned.

Example:
```json
"cdnProfileSku": "Premium_Verizon",
```

## cdnEndpointName
The name of the Azure CDN Endpoint to be provisioned.
This is the endpoint that is exposed to the internet for accessing the static website.
The CDN serves the static websites content from this endpoint.

Example:
```json
"cdnEndpointName": "static-website-endpoint-k0x-play5"
```

## cdnCustomDomainHostName
The customd domain host name to be used for the static website.

Example:
```json
"cdnCustomDomainHostName": "play5.mydomain.com",
```
