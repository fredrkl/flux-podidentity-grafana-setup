targetScope='subscription'

param resourceGroupName string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName  
  location: location
}

// Network and private DNS Zone
module network 'modules/network.bicep' = {
  scope: rg
  name: 'networking'
  params: {
    location: rg.location
  }
}

module storage 'modules/storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    privateEndpointStorageSubnetId: network.outputs.private_endpoint_subnet_id
    privateBlobDnsZoneId: network.outputs.private_DNS_Blob_Zone_id
    location: rg.location
    storagePrefix: 'mydemo'
  }
}
