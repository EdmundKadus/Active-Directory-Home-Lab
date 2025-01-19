#Create a variable for password that all users in the list would use#
$USERS_PASSWORD = "P@ssw0rd1"
#Pulls randomly generated names by chatgpt on a text file, there are about 50 names in it#
$USERS_NAMELIST = Get-Content .\user_list.txt



$password = ConvertTo-SecureString $USERS_PASSWORD -AsPlainText -Force
#Insert these users into my exist OU named Marketing#
Set-ADOrganizationalUnit -Identity "ou=Marketing,DC=edmundlabs,DC=com" -ProtectedFromAccidentalDeletion $false


#foreach loop

foreach ($n in $USERS_NAMELIST){
    
    $first = $n.Split("")[0].ToLower()
    $last = $n.Split("")[0].ToLower()
    #Append to create username, substring index the first letter of $first name#
    $username = "$($first.substring(0,1))$($last)".ToLower()
    Write-Host "Creating user: $($username)" -BackgroundColor Black -ForegroundColor Red

           New-AdUser -AccountPassword $password `
               -GivenName $first `
               -Surname $last `
               -DisplayName $username `
               -Name $username `
               -EmployeeID $username `
               -PasswordNeverExpires $true `
               -Path "ou=_Marketing,$(([ADSI]`"").distinguishedName)" `
               -Enabled $true
}