param location string = resourceGroup().location
param privateDnsZoneName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'demo-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/20'
      ]
    }
    subnets: [
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '10.0.0.0/28'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AKS'
        properties: {
          addressPrefix: '10.0.8.0/21'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

// Extend with private endpoint DNS group
resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateDnsZone}-DNS-Group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'BlobDnsGroup'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

output private_endpoint_subnet_id string = virtualNetwork.properties.subnets[0].id
output aks_subnet_id string = virtualNetwork.properties.subnets[1].id
