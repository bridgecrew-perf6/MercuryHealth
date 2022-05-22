param keyvaultName string
param secret_configStoreConnectionName string
param secret_ConnectionStringName string
param webappName string
param funcappName string

//param location string = resourceGroup().location
//param vaultName string

@secure()
param secret_configStoreConnectionValue string

@secure()
param secret_ConnectionStringValue string

@secure()
param appServiceprincipalId string

// @secure()
// param funcAppServiceprincipalId string

param tenant string = subscription().tenantId


// ******************************************
// Create KeyVault accessPolicies
// ******************************************
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: appServiceprincipalId
    permissions: {
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
    }
  }
  // {
  //   tenantId: tenant
  //   objectId: funcAppServiceprincipalId
  //   permissions: {
  //     keys: [
  //       'Get'
  //       'List'
  //     ]
  //     secrets: [
  //       'Get'
  //       'List'
  //     ]
  //   }
  // }
]

// Reference Existing resource
resource existing_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyvaultName
}

resource keyvaultaccessmod 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: 'add'
  parent: existing_keyvault
  properties: {
    accessPolicies: accessPolicies
  }
}


// Create KeyVault Secrets
resource secret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: '${existing_keyvault}/${secret_configStoreConnectionName}'
  properties: {
    value: secret_configStoreConnectionValue
  }
}

// create secret for Web App
resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: '${existing_keyvault}/${secret_ConnectionStringName}'
  properties: {
    contentType: 'text/plain'
    value: secret_ConnectionStringValue
  }
}
//create secret for Func App
// resource mySecret3 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${keyvaultName}/${secretName3}'
//   properties: {
//     contentType: 'text/plain'
//     value: secretAzureWebJobsStorage
//   }
// }
// create secret for Func App
// resource mySecret4 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${keyvaultName}/${secretName4}'
//   properties: {
//     contentType: 'text/plain'
//     value: secretAzureWebJobsStorage
//   }
// }


// Create Web sites/config 'appsettings' - Web App
// Reference Existing resource
resource existing_appService 'Microsoft.Web/sites@2021-03-01' existing = {
  name: webappName
}

resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2021-03-01' = {
  //name: '${webSiteName}/appsettings'
  name: 'appsettings'
  parent: existing_appService
  properties: {
    'ConnectionStrings:MercuryHealthWebContext': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secret_configStoreConnectionName})'
    'ConnectionStrings:AppConfig': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secret_ConnectionStringName})'
  }
}


// Create Web sites/config 'appsettings' - Function App

// resource symbolicname 'Microsoft.Web/sites/config@2021-03-01' = {
//   name: 'appsettings'
//   kind: 'string'
//   parent: resourceSymbolicName
//   properties: {}
// }
