targetScope = 'subscription'

param resourceGroupNameFoundry string

@allowed([
  'eastus2'
  'canadaeast'
])
param location string
param vnetAddressPrefix string
param subnetAgentAddressPrefix string
param subnetPrivateEndpointAddressPrefix string

param projectName string
param projectDisplayName string
param projectDescription string

resource rgFoundry 'Microsoft.Resources/resourceGroups@2025-03-01' = {
  name: resourceGroupNameFoundry
  location: location
}
var suffix = uniqueString(rgFoundry.id)

module virtualNetwork 'modules/network/virtualnetwork.bicep' = {
  scope: rgFoundry
  params: {
    location: location
    subnetAgentAddressPrefix: subnetAgentAddressPrefix
    vnetAddressPrefix: vnetAddressPrefix
    subnetPrivateEndpointAddressPrefix: subnetPrivateEndpointAddressPrefix
  }
}

/*
  An AI Foundry resources is a variant of a CognitiveServices/account resource type
*/

var aiFoundryResourceName = 'aifoundry-${suffix}'

module aiFoundry 'modules/aiservices/aifoundry.bicep' = {
  scope: rgFoundry
  params: {
    location: location
    resourceName: aiFoundryResourceName
    subnetResourceId: virtualNetwork.outputs.subnetAgentResourceId
  }
}

// module dnsfoundry 'modules/network/private.endpoint.dns.foundry.bicep' = {
//   scope: rgFoundry
//   params: {
//     aiAccountName: aiFoundry.outputs.aiFoundryResourceName
//     subnetResourceId: virtualNetwork.outputs.subnetPeResourceId
//     vnetResourceId: virtualNetwork.outputs.vnetResourceId
//   }
// }

/* Dependencies for agent */

module dependencies 'modules/aiservices/dependencies.bicep' = {
  scope: rgFoundry
  params: {
    location: location
    subnetResourceId: virtualNetwork.outputs.subnetPeResourceId
    suffix: suffix
  }
}

/* Create the initial project */

// module project 'modules/project/aiproject.bicep' = {
//   scope: rgFoundry
//   params: {
//     location: location
//     accountName: aiFoundry.outputs.aiFoundryResourceName
//     aiSearchName: dependencies.outputs.aiSearchResourceName
//     azureStorageName: dependencies.outputs.storageName
//     cosmosDBName: dependencies.outputs.cosmosDBAccountName
//     displayName: projectDisplayName
//     projectDescription: projectDescription
//     projectName: projectName
//   }
// }
