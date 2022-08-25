param baseName string = resourceGroup().name
param location string = resourceGroup().location
param storageName string
param storageContainerName string
param storageKey string
param iothubconnectionstring string

resource logs 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'logs-${baseName}'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${baseName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logs.id
  }
}

resource env 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: 'env-${baseName}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logs.properties.customerId
        sharedKey: logs.listKeys().primarySharedKey
      }
    }
  }
  resource daprComponentState 'daprComponents@2022-03-01' = {
    name: 'statestore'
    properties: {
      componentType: 'state.azure.blobstorage'
      version: 'v1'
      ignoreErrors: false
      initTimeout: '5s'
      secrets: [
        {
          name: 'storageaccountkey'
          value: storageKey
        }
      ]
      metadata: [
        {
          name: 'accountName'
          value: storageName
        }
        {
          name: 'containerName'
          value: storageContainerName
        }
        {
          name: 'accountKey'
          secretRef: 'storageaccountkey'
        }
      ]
      scopes: [
        'capp-home-api'
      ]
    }
  }
  resource daprComponentIotHub 'daprComponents@2022-03-01' = {
    name: 'iothub'
    properties: {
      componentType: 'bindings.azure.eventhubs'
      version: 'v1'
      ignoreErrors: false
      initTimeout: '5s'
      secrets: [
        {
          name: 'storageaccountkey'
          value: storageKey
        }
        {
          name: 'iothubconnectionstring'
          value: iothubconnectionstring
        }
      ]
      metadata: [
        {
          name: 'connectionString'
          secretRef: 'iothubconnectionstring'
        }
        {
          name: 'consumerGroup'
          value: '$Default'
        }
        {
          name: 'storageAccountName'
          value: storageName
        }
        {
          name: 'storageContainerName'
          value: storageContainerName
        }
        {
          name: 'storageAccountKey'
          secretRef: 'storageaccountkey'
        }
      ]
      scopes: [
        'capp-home-api'
      ]
    }
  }
}

output id string = env.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
