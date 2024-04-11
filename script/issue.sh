resgrp="testresgrp2404"
region="southeastasia"
storage_account_name="teststorage2404"
vm_name="testvm2404"
vm_usr="azureuser"
vm_pwd="testvmpwd2404!"
subscription_id="xxxx"

az group create --name $resgrp --location $region
az storage account create -n $storage_account_name -g $resgrp -l $region --sku Standard_LRS --kind BlobStorage --access-tier Hot
az vm create --resource-group $resgrp --name $vm_name --image win2016datacenter \
    --admin-username $vm_usr --admin-password  $vm_pwd
az vm identity assign -g $resgrp -n $vm_name --identities [system]
principal_id=$(az resource list -n $vm_name -g $resgrp --query [*].identity.principalId --out tsv)
az role assignment create --assignee $principal_id --role "Storage Blob Data Owner" \
    --scope subscriptions/$subscription_id/resourceGroups/$resgrp/providers/Microsoft.Storage/storageAccounts/$storage_account_name --debug 