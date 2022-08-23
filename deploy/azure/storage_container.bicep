@description('Name of the storage account')
param storageName string

@description('Name of the container')
param containerName string

resource StorageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageName}/default/${containerName}'
  properties: {}
}

output name string = StorageAccountContainer.name


