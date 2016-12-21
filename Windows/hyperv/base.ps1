cd C:\
$hypervPath = "C:\hyperv\"
If (-not (Test-Path $hypervPath)) { md $hypervPath }
$basePath = "C:\hyperv\base\"
If (-not (Test-Path $Path)) { md $hypervPath }
$webClient = New-Object System.Net.WebClient
$vhdFile = "9600.16415.amd64fre.winblue_refresh.130928-2229_server_serverdatacentereval_en-us.vhd"
$remotePath = "http://care.dlservice.microsoft.com/dl/download/5/8/1/58147EF7-5E3C-4107-B7FE-F296B05F435F/"
$remoteFile = "$remotePath$vhdFile"
$localFile = "$basePath$vhdFile"
$webClient.DownloadFile("$remoteFile","$localFile")
$vhdxFile = "9600.16415.amd64fre.winblue_refresh.130928-2229_server_serverdatacentereval_en-us.vhdx"
$newFile = "$basePath$vhdxFile"
Convert-VHD -Path "$localFile"  -DestinationPath "$newFile"
#rm "$localFile"

