$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fdatalake.azure.net%2F' -Method GET -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$AccessToken = $content.access_token
$result = Invoke-WebRequest -Uri https://securityhackstorage2404.blob.core.windows.net/securityhackcontainer2404/test.txt -Headers @{"x-ms-version"="2017-11-09"; Authorization="Bearer $AccessToken"}
$result.Content