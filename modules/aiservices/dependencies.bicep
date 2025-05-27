param location string
param suffix string
param subnetResourceId string

module privateDnsZoneCosmosDB 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    // Required parameters
    name: 'privatelink.documents.azure.com'
    // Non-required parameters
    location: 'global'
  }
}

/* CosmosDB Account */
module databaseAccount 'br/public:avm/res/document-db/database-account:0.15.0' = {
  name: 'databaseAccountDeployment'
  params: {
    // Required parameters
    name: 'cosmos-${suffix}'
    // Non-required parameters
    automaticFailover: true
    disableLocalAuthentication: true
    failoverLocations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    networkRestrictions: {
      networkAclBypass: 'AzureServices'
      publicNetworkAccess: 'Disabled'
    }
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneCosmosDB.outputs.resourceId
            }
          ]
        }
        service: 'Sql'
        subnetResourceId: subnetResourceId
      }
    ]
    zoneRedundant: false
  }
}

/* AI Search */

module privateDnsZoneAISearch 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    // Required parameters
    name: 'privatelink.search.windows.net'
    // Non-required parameters
    location: 'global'
  }
}

module searchService 'br/public:avm/res/search/search-service:0.10.0' = {
  params: {
    // Required parameters
    name: 'search-${suffix}'
    privateEndpoints: [
      {
        subnetResourceId: subnetResourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneAISearch.outputs.resourceId
            }
          ]
        }
      }
    ]
    disableLocalAuth: true
    hostingMode: 'default'
    location: location
    managedIdentities: {
      systemAssigned: true
    }
    networkRuleSet: {
      bypass: 'AzureServices'
    }
    partitionCount: 1
    replicaCount: 1
    sku: 'standard'
  }
}

/* Azure Storage */

module privateDnsZoneStorage 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    // Required parameters
    name: 'privatelink.blob.${environment().suffixes.storage}'
    // Non-required parameters
    location: 'global'
  }
}

var storageName = 'str${suffix}'

module storageAccount 'br/public:avm/res/storage/storage-account:0.20.0' = {
  params: {
    // Required parameters
    name: replace(storageName, '-', '')
    // Non-required parameters
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    publicNetworkAccess: 'Disabled'
    allowSharedKeyAccess: false
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: subnetResourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneStorage.outputs.resourceId
            }
          ]
        }
      }
    ]
  }
}

output storageName string = storageAccount.outputs.name
output cosmosDBAccountName string = databaseAccount.outputs.name
output aiSearchResourceName string = searchService.outputs.name
