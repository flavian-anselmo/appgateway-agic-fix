param appGateWayName string
param location string 
param applicationGatewaySkuCapacity  int 
param applicationGatewaySkuName string 
param applicationGatwaySkuTier string 
param vNetName string 
param appGatewaySubnetName string 
param gatewayIPConfigurationsName  string 

// PARAMS FOR NEW DEPLOYMENTS 
param publicIPAddressName  string 
param frontendPortsName string 
param backendAddressPoolName string 
param backendHttpSettingsCollectionName string 
param httpListenersName string 
param httpListenersProtocol string
param requestRoutingRulesName string 
param requestRoutingRulesRuleType string 
param frontendIPConfigurationsName string 
param backendHttpSettingsCollectionProtocol string 
param backendHttpSettingsCollectionCookieBasedAffinity string 

/// OUTPUTS FROM EXISTING GATEWAY
param backendPoolsOutputFromExisting array
param backendHttpSettingsCollectionOutput array
param httpListenersOutput array 
param urlPathsOutput array
param probeOutput array
param requestRoutingOutput array
param frontEndPortOutput array
param frontEndIpConfigOutput array 
param sslCertOutput array 


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  /**
  this repo assumes you laready have the vnet set up
  
  */
  name: vNetName
}


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' existing = {
  name: publicIPAddressName
  
}

resource appGateWays 'Microsoft.Network/applicationGateways@2022-07-01' ={
  name: appGateWayName
  location: location
  properties:{
    
    sku:{
      capacity:applicationGatewaySkuCapacity
      name:applicationGatewaySkuName
      tier:applicationGatwaySkuTier
    }

    frontendIPConfigurations:empty(frontEndIpConfigOutput)? [
      /**
      if the output from existing appgateway is empty 
      */
      {
        name: frontendIPConfigurationsName
        properties: {
           publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIPAddress.name)
           }
        }
      }
    ]:frontEndIpConfigOutput

    gatewayIPConfigurations:[
      {
        name: gatewayIPConfigurationsName
        properties:{
          subnet:{
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, appGatewaySubnetName)
          }
        }
      }
    ]

    frontendPorts: empty(frontEndPortOutput)?[
      {
        name: frontendPortsName
        properties: {
          port: 80
        }
      }
    ]:frontEndPortOutput

    backendAddressPools: empty(backendPoolsOutputFromExisting)?[
      {
        name:backendAddressPoolName
      }
    ]:backendPoolsOutputFromExisting

    backendHttpSettingsCollection: empty(backendHttpSettingsCollectionOutput)?[
      {
        name: backendHttpSettingsCollectionName
        properties: {
          port: 80
          protocol: backendHttpSettingsCollectionProtocol
          cookieBasedAffinity: backendHttpSettingsCollectionCookieBasedAffinity
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]:backendHttpSettingsCollectionOutput

    httpListeners: empty(httpListenersOutput)?[
      {
        name: httpListenersName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGateWayName, frontendIPConfigurationsName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGateWayName, frontendPortsName)
          }
          
          protocol: httpListenersProtocol
          requireServerNameIndication: false
        }
      }
    ]:httpListenersOutput

    requestRoutingRules: empty(requestRoutingOutput)?[
      {
        name: requestRoutingRulesName
        properties: {
          ruleType: requestRoutingRulesRuleType
          priority: 10
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGateWayName, httpListenersName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGateWayName, backendAddressPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGateWayName, backendHttpSettingsCollectionName)
          }
        }
      }
    ]:requestRoutingOutput

    urlPathMaps:empty(urlPathsOutput)?[]:urlPathsOutput

    probes:empty(probeOutput)?[]:probeOutput
    
    sslCertificates: empty(sslCertOutput)?[]:sslCertOutput
   
  }
}
