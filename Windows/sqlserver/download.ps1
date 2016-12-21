$mssqlPath = "C:\mssql\"
If (-not (Test-Path $mssqlPath)) { md $mssqlPath }
$webClient = New-Object System.Net.WebClient
$isoFile = "SQLServer2016-x64-ENU.iso"
$remotePath = "http://care.dlservice.microsoft.com/dl/download/F/E/9/FE9397FA-BFAB-4ADD-8B97-91234BC774B2/"
$remoteFile = "$remotePath$isoFile"
$localFile = "$basePath$isoFile"
$webClient.DownloadFile("$remoteFile","$localFile")

