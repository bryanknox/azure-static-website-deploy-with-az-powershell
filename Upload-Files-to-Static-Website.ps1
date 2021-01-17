# Upload files to a static website in Azure Storage.
#
# MSFT Docs: Host a static website in Azure Storage
# https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-powershell

param (
    [Parameter(Mandatory)] $EnvironmentName
)

$ErrorActionPreference = "Stop"

Write-Host "`nUpload files to a static website in Azure Storage`n"

#=================================================================================
# Load variables.
$scriptVariablesFilePath = "./Environments/$EnvironmentName.ScriptVariables.json"
Write-Host "Loading Variables from file: $scriptVariablesFilePath"
$variables = (Get-Content $scriptVariablesFilePath -Raw) | ConvertFrom-Json -AsHashtable

# ===========================================================================================
Write-Host "Get the storage account."
#
# Docs: Get-AzStorageAccount
# https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageaccount?view=azps-4.8.0
$storageAccount = Get-AzStorageAccount `
  -ResourceGroupName $variables['resourceGroupName'] `
  -Name $variables['websiteStorageAccountName'] `

# ===========================================================================================
Write-Host "Upload static website files to `$web container. Overwrites existing files."

Write-Host "From path: $($variables['websiteUploadFolderPath'])"

$fileEntries = Get-ChildItem -Path $variables['websiteUploadFolderPath']
foreach($filePath in $fileEntries) 
{ 
    Write-Host "`nUploading file: $($filePath.FullName)"   
    Write-Host "as: $($filePath.Name)"

  # Upload a file.
  #
  # Docs: Set-AzStorageBlobContent
  # https://docs.microsoft.com/en-us/powershell/module/az.storage/set-azstorageblobcontent?view=azps-4.8.0
  #
  # The -Properties parameter is used to configure the content type so that web browsers
  # will render the content of the files, instead of prompting the user to download them.

  Set-AzStorageBlobContent `
    -File $filePath `
    -Container '$web' `
    -Blob $filePath.Name `
    -Context $storageAccount.Context `
    -Properties @{ ContentType = "text/html; charset=utf-8"; } `
    -Force
}

Write-Host "`nDone.`n"
