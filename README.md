## A secured data access solution ##

This is a demo to present how to apply the following Azure Services to build a secured data transfer solution.
  * Azure Blob Storage
  * Azure Virtual Machine (VM)
  * Azure Conatiner Instance (ACI)
  * Azure Virtual Netwroks (VNet)
  * Azure  Managed Service Identity (MSI)

And the aims of this demo are
  * With VNet, no public access of Storage, VM and ACI
  * With MSI, no security key or token in the code
  
Create a demo Web App with Docker and ACI

```cmd
  az group create --name msirsgrp2021 --location westeurope
  az container create --resource-group msirsgrp2021 --name mycontainer --image mcr.microsoft.com/azuredocs/aci-helloworld --vnet aci-vm-vnet2 --vnet-address-prefix 10.0.0.0/16 --subnet aci-vm-subnet1 --subnet-address-prefix 10.0.0.0/24
  az network vnet subnet create -g msirsgrp2021 --vnet-name aci-vm-vnet2  -n aci-vm-subnet2 --address-prefixes 10.0.1.0/24
  az vm create --resource-group msirsgrp2021 --name myWinVM --image win2016datacenter --admin-username azureuser --admin-password  AAbbccdd123! --vnet-name aci-vm-vnet2 --subnet aci-vm-subnet2 --public-ip-address ""
  az vm identity assign -g msirsgrp2021 -n myWinVM --identities [system]
  az storage account create -n msistorage20210210 -g msirsgrp2021 -l westeurope --sku Standard_LRS --kind BlobStorage --access-tier Hot
  for /f %f in ('az storage account show-connection-string -g msirsgrp2021 -n msistorage20210210  --out tsv') do set conStr=%f
  az storage container create -n mystoragecontainer --connection-string %conStr%
  echo This is a test> test.txt
  az storage blob upload --account-name msistorage20210210 --connection-string %conStr% --container-name mystoragecontainer --file test.txt --name test.txt
  az storage account update -n msistorage20210210 -g msirsgrp2021 --bypass AzureServices --default-action Deny
  az network vnet subnet update -g msirsgrp2021 -n aci-vm-subnet2 --vnet-name aci-vm-vnet2 --service-endpoints Microsoft.Storage
  az storage account network-rule add -g msirsgrp2021 --account-name msistorage20210210 --vnet-name aci-vm-vnet2 --subnet aci-vm-subnet2
  for /f %f in ('az resource list -n myWinVM -g msirsgrp2021 --query [*].identity.principalId --out tsv') do set spID=%f
  az role assignment create --assignee %spID% --role "Storage Blob Data Owner" --scope /subscriptions/10609c53-2ee3-4ff1-b438-46f7e9de2cc6/resourceGroups/msirsgrp2021/providers/Microsoft.Storage/storageAccounts/msistorage20210210
```
Access the Windows VM via Azure Bastion
```cmd
  az network vnet subnet create -g msirsgrp2021 --vnet-name aci-vm-vnet2  -n AzureBastionSubnet --address-prefixes 10.0.2.0/24
  az network public-ip create --resource-group msirsgrp2021 --name MyBastionIp --sku Standard --location westeurope
  az network bastion create --name MyBastion --public-ip-address MyBastionIp --resource-group msirsgrp2021 --vnet-name aci-vm-vnet2 --location westeurope  
```


```Powershell
  $response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fdatalake.azure.net%2F' -Method GET -Headers @{Metadata="true"}
  $content = $response.Content | ConvertFrom-Json
  $AccessToken = $content.access_token
  $result = Invoke-WebRequest -Uri https://msistorage20210210.blob.core.windows.net/mystoragecontainer/test.txt -Headers @{"x-ms-version"="2017-11-09"; Authorization="Bearer $AccessToken"}

```
