#Created to Find All service running as Admin accros all servers (effect by password change)
#Creation date : 4-4-2018
#Creator: Alix N Hoover

Import-Module ActiveDirectory

$searchbase1 = "OU=servers,DC=x,DC=org"
##$searchbase2 = "OU=servers, DC=x2,DC=org"
##$searchbase3 = "OU=servers, DC=x3,DC=org"
$DOMAIN1 = "DC"
##$DOMAIN2 = "dpsdc05"
##$DOMAIN3 = "ntsrv1"


$htmlfile = "c:\temp\RunAsAdminService.html"
$errorfile = "c:\temp\error.txt"

#Email Info
$MailServer = "mail"
$recip = "ahoover@lme.org"
$sender = "Powershell@me.org"
$subject = "Services Running As Admin"

#Populate Server Array
$servers =@()
$servers = get-adcomputer -server $DOMAIN1 -searchbase $searchbase1 -filter * | ForEach-Object {$_.Name}
##$servers +=get-adcomputer -server $DOMAIN2 -searchbase $searchbase2 -filter * | ForEach-Object {$_.Name}
##$servers +=get-adcomputer -server $DOMAIN3 -searchbase $searchbase3 -filter * | ForEach-Object {$_.Name}

#Initate Failed Array
$failed=@()

# TABLE Service START
$html +="<HTML><BODY>
<table width='80%' align='center' border='1'>
<tr bgcolor='#32CD32'>
<td width='20%'>System Name</td>
<td width='15%'>Display Name</td>
<td width='15%'>Name</td>
<td width='15%'>State</td>
<td width='15%'>Status</td>
<td width='15%'>Start Mode</td>
<td width='15%'>Start Name</td>
</tr>"

 foreach ($server in $servers)
 #Open For Servers
 {
 
   if(Test-Connection $server -Count 2 -Quiet)
   #open If Connection
   {
    $temp = Get-WmiObject win32_Service -Computer $server -filter "StartName LIKE '%admin%'"|
     select SystemName, DisplayName, Name, State, Status, StartMode, StartName

     Foreach ($s in $temp)
     #open For S Loop
     {


$html +="<tr><td>$($s.SystemName)</td>
<td>$($s.DisplayName)</td>
<td>$($s.Name)</td>
<td>$($s.State)</td>
<td>$($s.Status)</td>
<td>$($s.StartMode)</td>
<td>$($s.StartName)</td></tr>"
} #Close For S Loop

     }#Close If Connection

     Else {$failed +=$server}
     }#Close For Servers

# TABLE Service End
$html +="</table></p></br><table align='center' border='1'><tr bgcolor='#32CD32'>
<td>Failed to connect to Systems</td></tr>"
foreach ($f in $failed)
#open failed loop
{
$html +="<tr><td>$($f)</td></tr>"

}#close failed loop


$html +="</table></BODY></HTML>"

#Export the File
$html | Out-File $htmlfile

#Email the Info
$Body = $html
Send-MailMessage -From $sender -To $recip -Subject $subject -Body ( $Body | out-string ) -BodyAsHtml -SmtpServer $MailServer
