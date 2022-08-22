param location string = resourceGroup().location

// // create the azure container registry
// resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
//   name: toLower('${resourceGroup().name}acr')
//   location: location
//   sku: {
//     name: 'Basic'
//   }
//   properties: {
//     adminUserEnabled: true
//   }
// }

// create the aca environment
module env 'environment.bicep' = {
  name: 'containerAppEnvironment'
  params: {
    location: location
  }
}

param registryName string = ''
param registryUserName string = ''
param registryPassword string = ''

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

// create the home api container app
module home 'container_app.bicep' = {
  name: 'home-api'
  params: {
    name: 'home-api'
    location: location
    registry: registryName
    registryUsername: registryUserName
    registryPassword: registryPassword
    repositoryImage: 'docker.io/samuelecozzi/thermostat-consumer:latest'
    containerAppEnvironmentId: env.outputs.id
    envVars: shared_config
    externalIngress: false
  }
}

// // create the inventory api container app
// module inventory 'container_app.bicep' = {
//   name: 'inventory'
//   params: {
//     name: 'inventory'
//     location: location
//     registryPassword: acr.listCredentials().passwords[0].value
//     registryUsername: acr.listCredentials().username
//     containerAppEnvironmentId: env.outputs.id
//     registry: acr.name
//     envVars: shared_config
//     externalIngress: false
//   }
// }

// // create the store api container app
// module store 'container_app.bicep' = {
//   name: 'store'
//   params: {
//     name: 'store'
//     location: location
//     registryPassword: acr.listCredentials().passwords[0].value
//     registryUsername: acr.listCredentials().username
//     containerAppEnvironmentId: env.outputs.id
//     registry: acr.name
//     envVars: shared_config
//     externalIngress: true
//   }
// }
