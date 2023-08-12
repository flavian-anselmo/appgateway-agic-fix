/**

-----------------------------------------
PREVENT BACKEND POOLS FROM BEING DELETED 
-----------------------------------------
This code snippet will pick all the required data from azure during deployment 
and store them in arrays. The arrays will then be passed in the actual deployment to  retain the backend pools ssl certs etc 

*/

param appGateWayName string
resource existingAppGateway 'Microsoft.Network/applicationGateways@2022-07-01' existing = {
  name:appGateWayName
}

output backendPoolsOutput array = existingAppGateway.properties.backendAddressPools
output backendHttpSettingsCollectionsOutput array = existingAppGateway.properties.backendHttpSettingsCollection
output probesOutput array = existingAppGateway.properties.probes
output httpListenersOutput array = existingAppGateway.properties.httpListeners
output urlPathsOutput array = existingAppGateway.properties.urlPathMaps
output requestRoutingRuleOutput array = existingAppGateway.properties.requestRoutingRules
output frontEndPortsOutput array = existingAppGateway.properties.frontendPorts
output frontEndIpsConfigOutput array = existingAppGateway.properties.frontendIPConfigurations
output sslCertOutput array = existingAppGateway.properties.sslCertificates
