param location string = resourceGroup().location

var privateBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'demo-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/12'
      ]
    }
    subnets: [
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '172.16.0.0/27'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AKS'
        properties: {
          addressPrefix: '172.16.8.0/21'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource privateBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateBlobDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateBlobDnsZone
  name: '${privateBlobDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

/*
// Extend with private endpoint DNS group
resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateDnsZone.name}/blobs'
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
}*/

output private_endpoint_subnet_id string = virtualNetwork.properties.subnets[0].id
output aks_subnet_id string = virtualNetwork.properties.subnets[1].id
output private_DNS_Blob_Zone_id string = privateBlobDnsZone.id
