$USERS_PASSWORD = "Password1"
$USERS_NAMELIST = Get-Content .\user_list.txt
$password = ConvertTo-SecureString $USERS_PASSWORD -AsPlainText -Force

# Specify the target OU explicitly
$targetOU = "OU=Marketing,DC=edmundlabs,DC=com" 

foreach ($n in $USERS_NAMELIST){
    $first = $n.Split(" ")[0].ToLower()
    $last = $n.Split(" ")[1].ToLower()
    $username = "$($first.Substring(0,1))$($last)".ToLower()
    Write-Host "Creating user: $($username)" -BackgroundColor Black -ForegroundColor Red

    # Add the -Path parameter to specify the target OU
    New-AdUser -AccountPassword $password `
               -GivenName $first `
               -Surname $last `
               -DisplayName $username `
               -Name $username `
               -EmployeeID $username `
               -PasswordNeverExpires $true `
               -Enabled $true `
               -Path $targetOU 
}
