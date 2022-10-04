@minLength(3)
@maxLength(11)
param storagePrefix string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'
param location string = resourceGroup().location

param vmAdminUsername string = 'us_a_22'
@secure()
param vmAdminPassword string = ''

var privateEndpointName = 'myPrivateEndpoint'
var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'
var privateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'

var publicIpAddressName = 'bastianTestVmIp'
var networkInterfaceName = 'bastianTestVmInterface'
var vmName = 'bastianVm'
var VmSize = 'Standard_D2_v3'
var osDiskType = 'StandardSSD_LRS'


// Network and private DNS Zone
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'demo-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.0/29'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '10.0.0.8/29'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'VMs'
        properties: {
          addressPrefix: '10.0.128.0/17'
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



resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'my-private-endpoint'
        properties: {
          privateLinkServiceId: stg.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: virtualNetwork.properties.subnets[1].id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// Bastion setup
// VM and Bastion
resource thePublicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'thePublicIpName'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: 'TheBastion'
  location: location
  properties:{
    ipConfigurations:[
      {
        id: 'theIp'
        name: 'thename'
        properties:{
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          } 
          publicIPAddress: {
            id: thePublicIp.id
          }
        }
      }
    ]
  }
}

//// The VMs
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIpAddressName
  location: location
  tags: {
    displayName: publicIpAddressName
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  tags: {
    displayName: networkInterfaceName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[2].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  tags: {
    displayName: vmName
  }
  properties: {
    hardwareProfile: {
      vmSize: VmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}



output storageEndpoint object = stg.properties.primaryEndpoints
output storageEndpointBlob string = stg.properties.primaryEndpoints.blob
