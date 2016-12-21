$exchangePath = "C:\exchange\"
If (-not (Test-Path $exchangePath)) { md $exchangePath }
$webClient = New-Object System.Net.WebClient
$exeFile = "Exchange2016-x64.exe"
$remotePath = "https://download.microsoft.com/download/3/9/B/39B8DDA8-509C-4B9E-BCE9-4CD8CDC9A7DA/"
$remoteFile = "$remotePath$exeFile"
$localFile = "$basePath$exeFile"
$webClient.DownloadFile("$remoteFile","$localFile")

