targetScope='subscription'

param resourceGroupName string
param clusterName string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

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
    privateEndpointSubnetId: network.outputs.private_endpoint_subnet_id
    privateBlobDnsZoneId: network.outputs.private_DNS_Blob_Zone_id
    location: rg.location
    storagePrefix: 'mydemo'
  }
}

module acr 'modules/acr.bicep' = {
  scope: rg
  name: 'acr'
  params: {
    location: rg.location
    privateEndpointSubnetId: network.outputs.private_endpoint_subnet_id
    privateAcrDnsZoneId: network.outputs.private_DNS_ACR_Zone_id
  }
}

module aks 'modules/aks.bicep' = {
  scope: rg
  name: 'AKS'
  params:{
    location: rg.location
    dnsPrefix: 'monitoring'
    clusterName: clusterName
    nodeSubnetId: network.outputs.aks_subnet_id
  }
}

output controlPlaneFQDN string = aks.outputs.controlPlaneFQDN
