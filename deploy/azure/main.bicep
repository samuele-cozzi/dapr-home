param location string = resourceGroup().location
param registryName string
param registryUserName string
param tag string
@secure()
param registryPassword string 

//create iothub
module iothub 'iothub.bicep' = {
  name: 'iot-home'
  params: {
    name: 'iot-smarthome-samuele'
    location: location
  }
}
//manual creation of devices

//create storage account
module storageaccount 'storage_account.bicep' = {
  name: 'storageaccount'
  params: {
    location: location
    storageName: 'storagesmarthome'
    tags: {
    }
  }
}

module function_storagecontainer 'storage_container.bicep' = {
  name: 'function_storagecontainer'
  params: {
    storageName: storageaccount.outputs.storageName
    containerName: 'functions'
  }
}

module state_storagecontainer 'storage_container.bicep' = {
  name: 'state_storagecontainer'
  params: {
    storageName: storageaccount.outputs.storageName
    containerName: 'state'
  }
}

// create the aca environment
module env 'container_environment.bicep' = {
  name: 'containerAppEnvironment'
  params: {
    location: location
    storageName: storageaccount.outputs.storageName
    storageContainerName: state_storagecontainer.outputs.name
    storageKey: storageaccount.outputs.accountKey
  }
}

// create the various config pairs
var shared_config = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: env.outputs.appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: env.outputs.appInsightsConnectionString
  }
]

// create the various config pairs
var iot_consumer_config = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: env.outputs.appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: env.outputs.appInsightsConnectionString
  }
  {
    name: 'AzureWebJobsStorage'
    value: storageaccount.outputs.connectionstring
  }
  {
    name: 'AzureEventHubConnectionString'
    value: iothub.outputs.connectionstring
  }
]

// create the home api container app
module home 'container_app.bicep' = {
  name: 'home-api'
  params: {
    name: 'capp-home-api'
    location: location
    registry: registryName
    registryUsername: registryUserName
    registryPassword: registryPassword
    repositoryImage: '${registryName}/${registryUserName}/home-api:${tag}'
    containerAppEnvironmentId: env.outputs.id
    envVars: shared_config
    externalIngress: false
  }
}

// create the home api container app
module iothub_consumer 'container_app.bicep' = {
  name: 'iothub-functions'
  params: {
    name: 'capp-thermostat-consumer'
    location: location
    registry: registryName
    registryUsername: registryUserName
    registryPassword: registryPassword
    repositoryImage: '${registryName}/${registryUserName}/thermostat-consumer:${tag}'
    containerAppEnvironmentId: env.outputs.id
    envVars: iot_consumer_config
    externalIngress: false
  }
}
