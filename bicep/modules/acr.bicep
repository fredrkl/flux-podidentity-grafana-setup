param location string = resourceGroup().location
//param privateEndpointSubnetId string = ''
//param privateAcrDnsZoneId string = ''

//var privateEndpointName = 'myPrivateAcrEndpoint'
var containerregistryname = 'fluxdemocontainerregistry'

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerregistryname
  location: location
  sku: {
    name: 'Premium'
  }
}

/*resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'my-private-endpoint-acr'
        properties: {
          privateLinkServiceId: acr.id
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: privateEndpointName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'acrendpointdnsgroup'
        properties: {
          privateDnsZoneId: privateAcrDnsZoneId 
        }
      }
    ]
  }
  dependsOn:[
    privateEndpoint
  ]
}
*/
