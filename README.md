# Application Gateway Ingress (AGIC) Controller Fix For Bicep 


When employing the AGIC add-on in Azure as the ingress controller for your microservices application, a noteworthy challenge arises. During the process of reprovisioning the infrastructure with Bicep, an unfortunate consequence emerges wherein the backend pools are inadvertently lost. This results in a disruption of service to your site, as traffic is unable to traverse through the Ingress. Additionally, the SSL certificates, which play a pivotal role in securing your application, are also forfeited.

Remarkably, this issue has persisted since April of 2021, without a definitive resolution. However, after a considerable period of experimentation and exploration, I have managed to uncover a pragmatic workaround to mitigate the associated disruptions.


## Github Issue Link 
[https://github.com/Azure/bicep/issues/2316](https://github.com/Azure/bicep/issues/2316)



## Workarrounds 

### #1 (NOT SCALABLE)

The first work around was to use if conditions in my bicep file but this was not a scalable solution since if i want to make achange to my application gateway I would still face a downtime. The code snippets are as shown below:-

```Bicep
// NOTE: THIS SOLUTION IS OK IF YOU WONT MODIFY YOUR APPLICATION GATEWAY 
@allowed([
  'new'
  'existing'
])
param newOrExistingAppGateway string = 'existing'
param appGatewayName string 

// EXISTING RESOURCE 
resource existingAppGateway 'Microsoft.Network/applicationGateways@2022-07-01' = if(newOrExistingAppGateway=='existing'){
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
So here if the parameter newOrExistingAppGateway is set to 'new', this means this is a new deployment and it will ignore the existing part of the code and viceversa.


### #2 (SCALABLE BUT WITH A CATCH TO IT )