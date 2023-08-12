param appGateWayName string
param location string 
param applicationGatewaySkuCapacity  int 
param applicationGatewaySkuName string 
param applicationGatwaySkuTier string 
param vNetName string 
param appGatewaySubnetName string 
param gatewayIPConfigurationsName  string 

// PARAMS FOR NEW DEPLOYMENTS IF THE APPLICATION GATEWAY DOES NOT EXIST 
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



@description('THis is an actual application gateway provison ')
module applicationGateway '../core/actualAppGateway.bicep'={
  name: 'appGateway'
  dependsOn:[
    
  ]
  params:{
    appGateWayName: appGateWayName
    applicationGatewaySkuCapacity: applicationGatewaySkuCapacity
    applicationGatewaySkuName: applicationGatewaySkuName
    applicationGatwaySkuTier: applicationGatwaySkuTier
    location:location
    appGatewaySubnetName: appGatewaySubnetName
    vNetName: vNetName
    backendAddressPoolName: backendAddressPoolName
    backendHttpSettingsCollectionCookieBasedAffinity: backendHttpSettingsCollectionCookieBasedAffinity
    backendHttpSettingsCollectionName: backendHttpSettingsCollectionName
    backendHttpSettingsCollectionProtocol: backendHttpSettingsCollectionProtocol
    frontendIPConfigurationsName: frontendIPConfigurationsName
    frontendPortsName: frontendPortsName
    gatewayIPConfigurationsName: gatewayIPConfigurationsName
    httpListenersName: httpListenersName
    httpListenersProtocol: httpListenersProtocol
    requestRoutingRulesName: requestRoutingRulesName
    requestRoutingRulesRuleType:requestRoutingRulesRuleType
    publicIPAddressName: publicIPAddressName
    backendPoolsOutputFromExisting: existingAppGateway.outputs.backendPoolsOutput
    frontEndPortOutput:existingAppGateway.outputs.frontEndPortsOutput
    httpListenersOutput:existingAppGateway.outputs.httpListenersOutput
    probeOutput:existingAppGateway.outputs.probesOutput
    requestRoutingOutput:existingAppGateway.outputs.requestRoutingRuleOutput
    sslCertOutput:existingAppGateway.outputs.sslCertOutput
    urlPathsOutput:existingAppGateway.outputs.urlPathsOutput
    backendHttpSettingsCollectionOutput:existingAppGateway.outputs.backendHttpSettingsCollectionsOutput
    frontEndIpConfigOutput:existingAppGateway.outputs.frontEndIpsConfigOutput
  }
}



@description('This refernces the above actual application gateway')
module existingAppGateway '../core/existingAppGateway.bicep' = {
  name:'existingGateway'
  params:{
    appGateWayName:appGateWayName
  }
}
