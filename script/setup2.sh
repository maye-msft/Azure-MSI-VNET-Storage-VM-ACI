
resgrp="securityhackvnet2404"
region="southeastasia"
vnet_name="hack-vnet"
vm_subnet_name="vm_subnet"
storage_account_name="securityhackstorage2404"
storage_container_name="securityhackcontainer2404"
vm_name="hellovm"
subscription_id="d9f2bb81-69a3-4962-9e65-e1c760c58551"

# create storage account
az storage account create -n $storage_account_name -g $resgrp -l $region --sku Standard_LRS --kind BlobStorage --access-tier Hot
conn_str=$(az storage account show-connection-string -g $resgrp -n $storage_account_name --out tsv)

# create storage container and upload a file
az storage container create -n $storage_container_name --connection-string $conn_str
echo This is a test> test.txt
az storage blob upload --account-name $storage_account_name --connection-string $conn_str --container-name $storage_container_name --file test.txt --name test.txt --overwrite

# disable the public network access of the storage account and add network rule to allow VM's subnet can access it.
az storage account update -n $storage_account_name -g $resgrp --bypass AzureServices --default-action Deny
az network vnet subnet update -g $resgrp -n $vm_subnet_name --vnet-name $vnet_name --service-endpoints Microsoft.Storage
az storage account network-rule add -g $resgrp --account-name $storage_account_name --vnet-name $vnet_name --subnet $vm_subnet_name

# create a managed identity for the VM and assign it a role of "Storage Blob Data Owner"
# https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
az vm identity assign -g $resgrp -n $vm_name --identities [system]
principal_id=$(az resource list -n $vm_name -g $resgrp --query [*].identity.principalId --out tsv)
az role assignment create --assignee $principal_id --role "Storage Blob Data Owner" \
    --scope subscriptions/$subscription_id/resourceGroups/$resgrp/providers/Microsoft.Storage/storageAccounts/$storage_account_name
   