param location string = resourceGroup().location
param privateEndpointSubnetId string = ''
param privateAcrDnsZoneId string = ''

var privateEndpointName = 'myPrivateAcrEndpoint'
var pvtEndpointDnsGroupName = '${privateEndpointName}-acr'
var containerregistryname = 'fluxdemocontainerregistry'

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerregistryname
  location: location
  sku: {
    name: 'Premium'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'myprivateendpointacr'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateAcrDnsZoneId 
        }
      }
    ]
  }
}
