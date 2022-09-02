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
    iothubconnectionstring: iothub.outputs.connectionstring
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
    externalIngress: true
  }
}

// create the home api container app
module ac_controller 'container_app.bicep' = {
  name: 'ui-ac-controller'
  params: {
    name: 'ui-ac-controller'
    location: location
    registry: registryName
    registryUsername: registryUserName
    registryPassword: registryPassword
    repositoryImage: '${registryName}/${registryUserName}/ui-ac-controller:${tag}'
    containerAppEnvironmentId: env.outputs.id
    envVars: shared_config
    externalIngress: true
  }
}
