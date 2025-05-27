param vnetAddressPrefix string
param subnetAgentAddressPrefix string
param subnetPrivateEndpointAddressPrefix string
param location string

module nsgAgent 'br/public:avm/res/network/network-security-group:0.5.1' = {
  params: {
    name: 'nsg-agent'
  }
}

module nsgPe 'br/public:avm/res/network/network-security-group:0.5.1' = {
  params: {
    name: 'nsg-pe'
  }
}

module vnet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  params: {
    name: 'vnet-agent'
    location: location
    addressPrefixes: [
      vnetAddressPrefix
    ]
    subnets: [
      {
        name: 'snet-agent'
        addressPrefix: subnetAgentAddressPrefix
        networkSecurityGroupResourceId: nsgAgent.outputs.resourceId
        delegation: 'Microsoft.app/environments'
      }
      {
        name: 'snet-pe'
        addressPrefix: subnetPrivateEndpointAddressPrefix
        networkSecurityGroupResourceId: nsgPe.outputs.resourceId
      }
    ]
  }
}

output vnetResourceId string = vnet.outputs.resourceId
output subnetAgentResourceId string = vnet.outputs.subnetResourceIds[0]
output subnetPeResourceId string = vnet.outputs.subnetResourceIds[1]
