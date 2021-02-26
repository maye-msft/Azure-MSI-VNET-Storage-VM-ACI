import logging
import uuid
import azure.functions as func
import os, uuid, requests
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient, __version__
import time; 

from azure.identity import DefaultAzureCredential


def writeBlob() : 

    try:
        # Prepere content
        content = uuid.uuid4().hex
        local_file_name = content+'.txt'
        account_url = 'https://msifuncstorage20210226.blob.core.windows.net/'

        # Apply managed identity
        default_credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(
            account_url = account_url,
            credential = default_credential
        )

        # create blob client
        blob_client = blob_service_client.get_blob_client(container='myblob', blob=local_file_name)

        # Upload the created file
        blob_client.upload_blob(content, overwrite=True)

        return content

    except Exception as ex:
        print('Exception:')
        print(ex)






def main(req: func.HttpRequest) -> func.HttpResponse:

    

    logging.info('Python HTTP trigger function processed a request.')


    msg = writeBlob()


    return func.HttpResponse(
            str(msg),
            status_code=200
    )
