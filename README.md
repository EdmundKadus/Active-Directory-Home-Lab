# Active-Directory VM Lab

### Introduction

I'm setting up this lab to get more exposure on AD. Not the best looking structure but I do plan on improving it and adding more sub-domain and replications.

### Key Takeaways

* Familiarity with the AD UI and the different tools & services alongside it 
* Understanding of forests, domains, OU and objects
* Enhanced knowledge of how network and DNS are applied in practice at higher OSI stack layers
* Powershell scripting to bulk add users

### Software Used

* Windows 10 Enterprise ISO
* Windows Server 2019 ISO
* Oracle Virtual Box (Couldn't get VMWare to boot unfortunately)
* Excalidraw
* Smartdraw
  
### Scenario

EdmundLabs, a local software company, has a root domain of edmundlabs.com and a single headquarters office with the following departments: IT, Human Resources, Finance, Marketing, and Developers. 

Here I will be focusing on mainly the Marketing Organizational Unit for the lab because it's kinda long to script out objects for all 5 departments. I might explore more on the MY sub domain in the future.

### AD Architecture

<img src="https://github.com/user-attachments/assets/af02b852-865a-4d07-97e4-68eb7e2ac16e" img/>

### Rough System Architecture 

Purpose : By setting up AD DS, DNS, Routing and Remote Access, we establish the foundation for a functional Active Directory domain. This includes user authentication, name resolution, and network connectivity for client machines.


 <img src="https://github.com/user-attachments/assets/614e7ca4-9387-42bd-8ff5-219d110798c8" />


### Set-Up

1. **Network Adapter Configurations**

We first ensure that the Domain Controller (DC) has two network adapters: an internal adapter and an internet-facing NAT adapter. The NAT adapter will obtain its IP from DHCP (router). We manually configure a preferred IP on the internal adapter, which will serve as a DNS server and a gateway for our client machine later.

![Screenshot 2025-01-19 233647](https://github.com/user-attachments/assets/d2e2ec6b-c288-4877-8e06-60c9a764a651)

We assign the first usable address of the 192.168.0.0 (Private class) to internal. The DNS can be either 192.168.0.1 or 127.0.0.1 as they pretty much point to the same thing, themselves. No default gateway is set as the DC serves as a gateway for the client machine.

![Screenshot 2025-01-19 233804](https://github.com/user-attachments/assets/f53eb775-7956-47eb-9caa-d9aebb715b5a)


    
   
2. **AD DS & DNS**

We proceed with setting up the Active Directory Domain Services (AD DS). During the process, we will be prompted for a root domain name, which will be edmundlabs.com.

![Screenshot 2025-01-19 235516](https://github.com/user-attachments/assets/b81e32d2-d21b-4afd-9e9b-a7343c64e89b)

Here we have the administrator account and using a root account is kinda question security-wise so we will delegate it to Christian Sazabi in the IT department.

![Screenshot 2025-01-20 005201](https://github.com/user-attachments/assets/099dfd28-bd5d-4d53-8add-e2136fc1fb78)

![Screenshot 2025-01-20 024313](https://github.com/user-attachments/assets/c5425dea-c1bf-4713-8a8d-30071da14bfc)


Creation of the department OUs, there's definitely a better way I can format the file system but this will do for now.

![Screenshot 2025-01-20 024114](https://github.com/user-attachments/assets/141ea377-57c4-4d57-b576-21fa15c5944c)




3. **Routing & Remote Access**

We will set the routing server for NAT.

![Screenshot 2025-01-20 024755](https://github.com/user-attachments/assets/69876c18-f46a-4883-8a78-0b1909730be5)

Both NICs are detected.

![Screenshot 2025-01-20 025849](https://github.com/user-attachments/assets/3ea935ef-4ba3-4446-af36-22fde0c4ea33)
   
4. **DHCP Scoping**

Remember the client has an internal NIC which has not been dynamically assigned a private IP. We will set up the DHCP server which will be configured with a range of IP address, in our case 192.168.0.100 ~ 200 with net mask /24. The client will lease an IP address from that pool, usually the 1st one. We can do use ipconfig /release & renew to get another address from the pool, no practical use in this lab though with only 1 machine it'll probably end up being the same address.

![Screenshot 2025-01-20 031052](https://github.com/user-attachments/assets/40877f14-4f0f-4c47-8065-4050449a1c7f)

Specify our gateway where the client can point to, DC's internal NIC 192.168.0.1.

![Screenshot 2025-01-20 031819](https://github.com/user-attachments/assets/6a04dbd7-a703-4f93-9619-a2619a6c1b3c)

Pool established

![Screenshot 2025-01-20 031910](https://github.com/user-attachments/assets/9a8f47a4-ded6-47b8-8e21-f3fa08929f79)


### Powershell script to add 50 users into the Marketing OU. user_list.txt is a list of random names I got chat-gpt to come up with.

Password variable with a hard code dummy password, $USERS_NAMELIST will pull the 50 names from the text file.
```
$USERS_PASSWORD = "Password1"
$USERS_NAMELIST = Get-Content .\user_list.txt
$password = ConvertTo-SecureString $USERS_PASSWORD -AsPlainText -Force

```
Set a path for the established OU.
```
$targetOU = "OU=Marketing,DC=edmundlabs,DC=com"

```

Foreach loop every name in the text file. The names are split from the blank space, index [0] & [1] will pick out the first letter of the first names for the username convention.
```

foreach ($n in $USERS_NAMELIST){
    $first = $n.Split(" ")[0].ToLower()
    $last = $n.Split(" ")[1].ToLower()
    $username = "$($first.Substring(0,1))$($last)".ToLower()
    Write-Host "Creating user: $($username)" -BackgroundColor Black -ForegroundColor Red
```
Pairing our variables with the schema, there is always options such as PasswordNeverExpires and plenty of other settings available. The path sets where the users will be added to.
```
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
```
Users added in the Marketing OU.

![Screenshot 2025-01-20 053448](https://github.com/user-attachments/assets/42586bc0-2c46-40df-9b6b-716182c15dc8)

### Client Machine

Having set up the client machine, we will first do a ipconfig /all to check if the NIC has been set. 192.168.0.100 is leased from the DHCP Pool, default gateway is pointed to the DC.

![Screenshot 2025-01-20 061416](https://github.com/user-attachments/assets/acf8d7bf-bbca-472b-936d-eed89c4fff33)

DHCP is leased as shown here:

![Screenshot 2025-01-20 062005](https://github.com/user-attachments/assets/f5039b12-6fe0-4856-afcd-b3c9542342c1)


Client is able to ping google.com and domain edmundlabs.com

![Screenshot 2025-01-20 061540](https://github.com/user-attachments/assets/abd46f9f-5122-4919-b321-465e4e6554b0)
![Screenshot 2025-01-20 061618](https://github.com/user-attachments/assets/2ab9be33-0392-4a42-b8a0-f6f1e77afdc3)

We then make the client machine join the edmundlab.com domain so the users on there are able to log-in to that machine.

![Screenshot 2025-01-20 061754](https://github.com/user-attachments/assets/828ed033-f2ac-445b-986a-130101d47c86)

Administrative prompt, we can use Christian Sazabi from the IT department.

![Screenshot 2025-01-20 061820](https://github.com/user-attachments/assets/3334cddf-d8a5-4dd6-8f30-a209286185f3)

Successful login with a user account ekadus from Marketing.

![Screenshot 2025-01-20 062140](https://github.com/user-attachments/assets/2c2e17fb-63b4-491d-b4b4-9be1e0d3ec32)
![Screenshot 2025-01-20 062340](https://github.com/user-attachments/assets/429c2a30-ac58-446f-b8ce-d82cfa14d970)

### Additional: Prompt users for password reset on next logon 

Christian Sazabi from the IT department can perform various account services: Password & Lockout reset e.g.

![Screenshot 2025-01-20 072333](https://github.com/user-attachments/assets/33beb658-a93a-44b9-809f-5135f25e9276)

User is prompted.

![Screenshot 2025-01-20 072404](https://github.com/user-attachments/assets/53084841-9cff-438b-8498-3ee247e3d1be)


### TBC: Applying group policies and gpupdate



