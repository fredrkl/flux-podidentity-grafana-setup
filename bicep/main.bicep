targetScope='subscription'

//@minLength(3)
//@maxLength(11)
//param storagePrefix string

param resourceGroupName string
param location string


// Resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName  
  location: location
}

//var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'
var privateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
//var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'


// Network and private DNS Zone
module network 'modules/network.bicep' = {
  scope: rg
  name: 'networking'
  params: {
    privateDnsZoneName: privateDnsZoneName
    location: rg.location
  }
}

/*
module storage 'modules/storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    privateEndpointStorageSubnetId: network.outputs.private_endpoint_subnet_id
    location: rg.location

  }
}*/
