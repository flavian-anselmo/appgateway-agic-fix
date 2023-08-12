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

module actualGateway '../actualAppGateway.bicep'={
  name:'actualGateway'
  params:{
    appGateWayName:appGateWayName
    appGatewaySubnetName:appGatewaySubnetName
    applicationGatewaySkuCapacity:applicationGatewaySkuCapacity
    applicationGatewaySkuName:applicationGatewaySkuName
    applicationGatwaySkuTier:applicationGatwaySkuTier
    backendAddressPoolName:backendAddressPoolName
    backendHttpSettingsCollectionCookieBasedAffinity:backendHttpSettingsCollectionCookieBasedAffinity
    backendHttpSettingsCollectionName:backendHttpSettingsCollectionName
    backendHttpSettingsCollectionOutput:backendHttpSettingsCollectionOutput
    backendHttpSettingsCollectionProtocol:backendHttpSettingsCollectionProtocol
    backendPoolsOutputFromExisting:backendPoolsOutputFromExisting
    frontEndIpConfigOutput:frontEndIpConfigOutput
    frontendIPConfigurationsName:frontendIPConfigurationsName
    frontEndPortOutput:frontEndPortOutput
    frontendPortsName:frontendPortsName
    gatewayIPConfigurationsName:gatewayIPConfigurationsName
    httpListenersName:httpListenersName
    httpListenersOutput:httpListenersOutput
    httpListenersProtocol:httpListenersProtocol
    location:location
    probeOutput:probeOutput
    publicIPAddressName:publicIPAddressName
    requestRoutingOutput:requestRoutingOutput
    requestRoutingRulesName:requestRoutingRulesName
    requestRoutingRulesRuleType:requestRoutingRulesRuleType
    sslCertOutput:sslCertOutput
    urlPathsOutput:urlPathsOutput
    vNetName:vNetName
  }
}


module existingGateway '../existingAppGateway.bicep' ={
  name:'existingGateway'
  params:{
    appGateWayName:appGateWayName
  }
}
