# ██████╗░██╗░░░██╗███████╗███████╗  ███╗░░██╗███████╗██████╗░██████╗░
# ██╔══██╗██║░░░██║██╔════╝██╔════╝  ████╗░██║██╔════╝██╔══██╗██╔══██╗
# ██████╦╝██║░░░██║█████╗░░█████╗░░  ██╔██╗██║█████╗░░██████╔╝██║░░██║
# ██╔══██╗██║░░░██║██╔══╝░░██╔══╝░░  ██║╚████║██╔══╝░░██╔══██╗██║░░██║
# ██████╦╝╚██████╔╝██║░░░░░██║░░░░░  ██║░╚███║███████╗██║░░██║██████╔╝
# ╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░  ╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝╚═════╝░

# Automation Script that Restores a departmental OU from a backup file

# Check for the existence of an Active Directory Organizational Unit (OU) named "Finance"
$ouExists = Get-ADOrganizationalUnit -Filter { Name -eq "Finance" } -ErrorAction SilentlyContinue

if ($ouExists) {
    # OU exists, delete it
    Remove-ADOrganizationalUnit -Identity "OU=Finance,DC=consultingfirm,DC=com" -Recursive -Confirm:$false
    Write-Host "The 'Finance' OU already existed and has been deleted."
} else {
    Write-Host "The 'Finance' OU does not exist."
}

# Create an OU named "Finance"
New-ADOrganizationalUnit -Name "Finance" -Path "DC=consultingfirm,DC=com"
Write-Host "The 'Finance' OU has been created."

# Import financePersonnel.csv into Active Directory domain and into the finance OU
Import-Csv -Path "$PSScriptRoot\financePersonnel.csv" | ForEach-Object {
    New-ADUser -Name "$($_.'First_Name') $($_.'Last_Name')" -GivenName $_.'First_Name' -Surname $_.'Last_Name' `
               -DisplayName "$($_.'First_Name') $($_.'Last_Name')" -SamAccountName $_.'First_Name' -UserPrincipalName "$($_.'First_Name')$($_.'Last_Name')@consultingfirm.com" `
               -PostalCode $_.'PostalCode' -OfficePhone $_.'OfficePhone' -MobilePhone $_.'MobilePhone' -Path "OU=Finance,DC=consultingfirm,DC=com" -PassThru
}

# Generate output file for submission
Get-ADUser -Filter * -SearchBase "ou=Finance,dc=consultingfirm,dc=com" -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > ".\Requirements2\AdResults.txt"
