param location string = resourceGroup().location

var containerregistryname = 'flux-demo-container-registry'

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerregistryname
  location: location
  sku: {
    name: 'Basic'
  }
}
