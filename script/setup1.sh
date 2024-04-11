
resgrp="securityhackvnet2404"
region="southeastasia"
container_name="helloaci"
image_name="mcr.microsoft.com/azuredocs/aci-helloworld"
vnet_name="hack-vnet"
aci_subnet_name="aci_subnet"
vm_subnet_name="vm_subnet"
vm_name="hellovm"
vm_usr="azureuser"
vm_pwd="secminihack2404!"

# Create the resource group
az group create --name $resgrp --location $region

# Create the ACI, VNet and subnet 10.0.0.0/24
az container create --resource-group $resgrp --name $container_name --image $image_name \
    --vnet $vnet_name --vnet-address-prefix 10.0.0.0/16 --subnet $aci_subnet_name --subnet-address-prefix 10.0.0.0/24

# Create subnet for VM 10.0.1.0/24
az network vnet subnet create -g $resgrp --vnet-name $vnet_name  -n $vm_subnet_name --address-prefixes 10.0.1.0/24

# Create VM and disable public IP address
az vm create --resource-group $resgrp --name $vm_name --image win2016datacenter \
    --admin-username $vm_usr --admin-password  $vm_pwd --vnet-name $vnet_name --subnet $vm_subnet_name --public-ip-address ""

# Create subnet for Bastion 10.0.2.0/24
az network vnet subnet create -g $resgrp --vnet-name $vnet_name -n AzureBastionSubnet --address-prefixes 10.0.2.0/24

# Create public ip for bastion
az network public-ip create --resource-group $resgrp --name MyBastionIp --sku Standard --location $region

# Create bastion
az network bastion create --name MyBastion --public-ip-address MyBastionIp \
    --resource-group $resgrp --vnet-name $vnet_name --location $region  



   