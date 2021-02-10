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

  az group create --name msirsgrp2021 --location eastus
  az container create --resource-group msirsgrp2021 --name mycontainer --image mcr.microsoft.com/azuredocs/aci-helloworld --vnet aci-vm-vnet2 --vnet-address-prefix 10.0.0.0/16 --subnet aci-vm-subnet1 --subnet-address-prefix 10.0.0.0/24
  az network vnet subnet create -g msirsgrp2021 --vnet-name aci-vm-vnet2  -n aci-vm-subnet2 --address-prefixes 10.0.1.0/24
  az vm create --resource-group msirsgrp2021 --name myWinVM --image win2016datacenter --admin-username azureuser --admin-password  AAbbccdd123! --vnet-name aci-vm-vnet2 --subnet aci-vm-subnet2 --public-ip-address ""
  az vm identity assign -g msirsgrp2021 -n myWinVM --identities [system]

  
