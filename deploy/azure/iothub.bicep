param name string
param skuName string = 'F1'
param skuCapacity int = 1
param location string = resourceGroup().location

resource iothub 'Microsoft.Devices/IotHubs@2020-04-01' = {
  name: name
  location: location
  sku: {
      name: skuName
      capacity: skuCapacity
  }
}

// Output our variables
output connectionstring string = listKeys(iothub.id, iothub.apiVersion).primaryConnectionString
