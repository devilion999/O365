#****************************************************#
#********resync local ad user to exist o365 mailbox**#
#**************Created By Devilion ******************#
#***************** Date 25/1/2024 *******************#
#****************************************************#

$UPN = Read-Host "Please enter the mailbox UPN"
$ImmutableId = Read-Host "Please enter the ObjectGUID"

ldifde -f export.txt -r "(Userprincipalname=$UPN)" -l "objectGuid, userPrincipalName"
Get-Content export.txt

# Check if MSOnline module is installed
if (-not (Get-Module -ListAvailable -Name MSOnline)) {
    # Install MSOnline module if not installed
    Install-Module -Name MSOnline -Force -Scope CurrentUser
}

# Import MSOnline module
Import-Module MSOnline

# Connect to MSOnline service
Connect-MsolService

# Set ImmutableId for the user
Set-MsolUser -UserPrincipalName $UPN -ImmutableId $ImmutableId
