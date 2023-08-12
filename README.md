# Application Gateway Ingress (AGIC) Controller Fix For Bicep 


When employing the AGIC add-on in Azure as the ingress controller for your microservices application, a noteworthy challenge arises. During the process of reprovisioning the infrastructure with Bicep, an unfortunate consequence emerges wherein the backend pools are inadvertently lost. This results in a disruption of service to your site, as traffic is unable to traverse through the Ingress. Additionally, the SSL certificates, which play a pivotal role in securing your application, are also forfeited.

Remarkably, this issue has persisted since April of 2021, without a definitive resolution. However, after a considerable period of experimentation and exploration, I have managed to uncover a pragmatic workaround to mitigate the associated disruptions.


## Github Issue Link 
[https://github.com/Azure/bicep/issues/2316](https://github.com/Azure/bicep/issues/2316)



## Workarrounds 

### #1 (NOT SCALABLE)

The initial workaround involved utilizing conditional statements in my Bicep file. However, this approach lacked scalability, as any modifications to the application gateway would still result in downtime. The code snippets are provided below for reference:

```Bicep
// NOTE: THIS SOLUTION IS OK IF YOU WONT MODIFY YOUR APPLICATION GATEWAY 
@allowed([
  'new'
  'existing'
])
param newOrExistingAppGateway string = 'existing'
param appGatewayName string 

// EXISTING RESOURCE 
resource existingAppGateway 'Microsoft.Network/applicationGateways@2022-07-01' = 
if (newOrExistingAppGateway=='existing'){
  name:appGatewayName
}


// NEW RESOURCE 
resource appGateWay 'Microsoft.Network/applicationGateways@2022-07-01' = if
(newOrExistingAppGateway=='new'){
  name: appGateWayName
  location: location
  properties:{}
}
   
```
In this context, if the parameter newOrExistingAppGateway is set to 'new', it signifies a new deployment, causing the existing part of the code to be ignored. Conversely, if set to 'existing', the new deployment will be disregarded.


### #2 (SCALABLE BUT WITH A CATCH TO IT )
In this workaround, I am utilizing Bicep outputs to retrieve data regarding backend pools and SSL certificates, both of which are in array data type. Subsequently, I pass this data to the application gateway, thereby enabling me to make modifications without causing any downtime to the system. For the implementation of this solution, two distinct files are required: one for referencing an existing application gateway and another for the regular or new application gateway deployment. Provided below is a code snippet for your reference:

```Bicep 

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


```

You will then create a module for both the existing and new deployment and pass this outputs in the actual deployment application gateway module as parameters like shown below:-

```Bicep 


@description('THis is an actual application gateway provison ')
module applicationGateway '../core/actualAppGateway.bicep'={
  name: 'appGateway'

  params:{
    appGateWayName: appGateWayName
    applicationGatewaySkuCapacity: applicationGatewaySkuCapacity
    applicationGatewaySkuName: applicationGatewaySkuName
    applicationGatwaySkuTier: applicationGatwaySkuTier
    location:location
    appGatewaySubnetName: appGatewaySubnetName
    vNetName: vNetName

    // USED DURING THE FIRST DEPLOYMENT WHEN N APPLICATION GATEWAY DOESNOT EXIST 
    //---------------------------------------------------------------------
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

    //--------------------------------------------------------------------

    //THE PART WITH OUTPUTS 
    //--------------------------------------------------------------------------
    backendPoolsOutputFromExisting: existingAppGateway.outputs.backendPoolsOutput
    frontEndPortOutput:existingAppGateway.outputs.frontEndPortsOutput
    httpListenersOutput:existingAppGateway.outputs.httpListenersOutput
    probeOutput:existingAppGateway.outputs.probesOutput
    requestRoutingOutput:existingAppGateway.outputs.requestRoutingRuleOutput
    sslCertOutput:existingAppGateway.outputs.sslCertOutput
    urlPathsOutput:existingAppGateway.outputs.urlPathsOutput
    backendHttpSettingsCollectionOutput:existingAppGateway.outputs.backendHttpSettingsCollectionsOutput
    frontEndIpConfigOutput:existingAppGateway.outputs.frontEndIpsConfigOutput
    //--------------------------------------------------------------------------------
  }
}



@description('This refernces the above actual application gateway')
module existingAppGateway '../core/existingAppGateway.bicep' = {
  name:'existingGateway'
  params:{
    appGateWayName:appGateWayName
  }
}


```

## The Catch to it 

In scenarios where it's the initial or first  deployment and the application gateway doesn't yet exist, referencing an existing application gateway isn't possible. To address this challenge, we can take a partial approach to resolving the issue using the empty() function in Bicep. This function evaluates whether an array is empty. If it is indeed empty, we can supply empty arrays along with a placeholder backend pool name. When the ingress is established in the cluster, these placeholder backend pools will be automatically removed, ensuring the website becomes operational.

This process can be orchestrated through a pipeline that applies the necessary manifest files, including ingress and certmanager for SSL certificates. The empty() function can be implemented as demonstrated below:

```Bicep 
// if empty, deploy dummy ports or names else use the outputs from the existing application gateway 
// NOTE: see codebase for other parameters with the empty function 

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

```

### Drawback for the solution 
You won't encounter any downtime. However, during the initial deployment, the pipeline might fail because it references a non-existent application gateway. The positive aspect is that other resources will still be provisioned, including the actual application gateway.

Given the choice between a failing pipeline and experiencing downtime, I would opt for a failing pipeline since it doesn't impact any functionality.

### Prevent your pipline from failing 

To prevent the pipeline from failing, we can compose a bash script that checks for the existence of the application gateway. This script would then set a boolean parameter in Bicep. With an accompanying if condition in Bicep, we can instruct it to disregard the existing reference if the application gateway is absent. This way, the Bicep script can proceed to deploy the actual application gateway, regardless of whether the check returns a true or false result.


```Bicep
// ASSUME newOrExistingAppGateway  IS THE VALUE FROM THE BASH SCRIPT OR YOU CAN JUST DO IT MANUALLY 
param newOrExistingAppGateway bool = true 


param appGatewayName string 


// EXISTING RESOURCE 
resource existingAppGateway 'Microsoft.Network/applicationGateways@2022-07-01' = 
if (newOrExistingAppGateway==true){
  name:appGatewayName
}


// NEW RESOURCE will be deployed even since all conditions are passing 
resource appGateWay 'Microsoft.Network/applicationGateways@2022-07-01' = if
(newOrExistingAppGateway==true | newOrExistingAppGateway==false ){
  name: appGateWayName
  location: location
  properties:{}
}
```
NOTE: CONTRIBUTE IF YOU HAVE MORE IDEAS (make a PR )
