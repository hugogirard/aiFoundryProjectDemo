param resourceName string
param location string
param subnetResourceId string

var networkInjection = 'true'

#disable-next-line BCP036
resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: resourceName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: resourceName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Disabled'
    networkInjections: ((networkInjection == 'true')
      ? [
          {
            scenario: 'agent'
            subnetArmId: subnetResourceId
            useMicrosoftManagedNetwork: false
          }
        ]
      : null)
    // true is not supported today
    disableLocalAuth: false
  }
}

// resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
//   name: resourceName
//   location: location
//   sku: {
//     name: 'S0'
//   }
//   kind: 'AIServices'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     allowProjectManagement: true
//     customSubDomainName: resourceName
//     networkAcls: {
//       defaultAction: 'Allow'
//       virtualNetworkRules: []
//       ipRules: []
//     }
//     publicNetworkAccess: 'Disabled'
//     networkInjections: {
//       scenario: 'agent'
//       subnetArmId: subnetResourceId
//       useMicrosoftManagedNetwork: false
//     }
//     // true is not supported today
//     disableLocalAuth: false
//   }
// }

output aiFoundryResourceName string = account.name
