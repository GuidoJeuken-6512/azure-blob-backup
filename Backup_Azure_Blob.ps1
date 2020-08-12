## Script copies Azure Blob Container to onPrem and sends a result mail.
## old AzCopy logs and plans will be deletet --> $delOlderDays
## $source must include a valid SAS Token with BLOB RW rights
## AzCopy must exist / download it from Microsoft
## Guido Jeuken
## Version 1.0
## 2020-8-12

## configure your values
$AzCopyPath = "c:\temp\azcopy.exe"
$source="https://yourstorage.blob.core.windows.net/yourContainer-Name?YourSAS-Key"
$dest = "d:\backup\dir"
$optons = " --recursive"
#Mail Server Variables
$recipients = "error@YourDomain"
$smtpServer = "YourMailServerNameOrIP"
$smtpFrom = "AzureBackup@YourDomain"
$messageSubject = "daily Backup Azure Storage Result"
##Days to keep azCopy Logs and plan-retry Infos
$delOlderDays=-3
## End variables to configure
## get default AzCopy logDirPath
$azCopyLogDir=$env:USERPROFILE + "\.azcopy"

## Execute AzCopy and store return values
$azlog = $AzCopyPath sync $source $dest --recursive

##send results as Mail
foreach($rec in $recipients){
    Send-MailMessage -To $rec -From $smtpFrom -Subject $messageSubject  -encoding ASCII -body  $azlog.ToString()  -smtpserver $smtpServer
}
##delete old Log and plan Files
$CurrDay=get-date
$DateToDelete = $CurrDay.AddDays($delOlderDays)
Get-ChildItem $azCopyLogDir | Where-Object {$_.LastwriteTime -lt $DateToDelete} | Remove-Item
## delete plan files
$azCopyLogDir =$azCopyLogDir + "\plans"
Get-ChildItem $azCopyLogDir | Where-Object {$_.LastwriteTime -lt $DateToDelete} | Remove-Item
