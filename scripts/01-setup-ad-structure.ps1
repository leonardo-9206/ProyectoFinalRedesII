# ==============================================================================
# Script: 01-setup-ad-structure.ps1
# Propósito: Creación automatizada de OUs, Grupos de Seguridad y Usuarios
# Dominio: redes2.local (NetBIOS: REDES2)
# Ejecutar en: DC01 (PowerShell como Administrador del Dominio)
# ==============================================================================

Write-Host ">>> Iniciando creación de Unidades Organizativas (OUs)..." -ForegroundColor Cyan
New-ADOrganizationalUnit -Name "Empresa" -Path "DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "TI" -Path "OU=Empresa,DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "Desarrollo" -Path "OU=Empresa,DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "Administracion" -Path "OU=Empresa,DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "Equipos" -Path "OU=Empresa,DC=redes2,DC=local"

Write-Host ">>> Creando Grupos de Seguridad..." -ForegroundColor Cyan
New-ADGroup -Name "GRP_TI" -GroupScope Global -GroupCategory Security -Path "OU=TI,OU=Empresa,DC=redes2,DC=local"
New-ADGroup -Name "GRP_LinuxAdmins" -GroupScope Global -GroupCategory Security -Path "OU=TI,OU=Empresa,DC=redes2,DC=local"
New-ADGroup -Name "GRP_Desarrollo" -GroupScope Global -GroupCategory Security -Path "OU=Desarrollo,OU=Empresa,DC=redes2,DC=local"
New-ADGroup -Name "GRP_Administracion" -GroupScope Global -GroupCategory Security -Path "OU=Administracion,OU=Empresa,DC=redes2,DC=local"

Write-Host ">>> Creando Usuarios de Laboratorio..." -ForegroundColor Cyan
$pass = ConvertTo-SecureString "Redes2026!" -AsPlainText -Force

# Joao Admin (TI / LinuxAdmins)
New-ADUser -Name "Joao Admin" -SamAccountName "joao.admin" -UserPrincipalName "joao.admin@redes2.local" `
  -Path "OU=TI,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

# Joshua Cliente (Administracion)
New-ADUser -Name "Joshua Cliente" -SamAccountName "josh.user" -UserPrincipalName "josh.user@redes2.local" `
  -Path "OU=Administracion,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

# Rodrigo Linux (Desarrollo)
New-ADUser -Name "Rodrigo Linux" -SamAccountName "rodri.dev" -UserPrincipalName "rodri.dev@redes2.local" `
  -Path "OU=Desarrollo,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

# Leonardo Servicios (Desarrollo)
New-ADUser -Name "Leonardo Servicios" -SamAccountName "leo.dev" -UserPrincipalName "leo.dev@redes2.local" `
  -Path "OU=Desarrollo,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

# Antonio Redes (TI)
New-ADUser -Name "Antonio Redes" -SamAccountName "antonio.ti" -UserPrincipalName "antonio.ti@redes2.local" `
  -Path "OU=TI,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

Write-Host ">>> Asignando usuarios a sus respectivos grupos..." -ForegroundColor Cyan
Add-ADGroupMember -Identity "GRP_TI" -Members "joao.admin", "antonio.ti"
Add-ADGroupMember -Identity "GRP_LinuxAdmins" -Members "joao.admin"
Add-ADGroupMember -Identity "GRP_Desarrollo" -Members "rodri.dev", "leo.dev"
Add-ADGroupMember -Identity "GRP_Administracion" -Members "josh.user"

Write-Host ">>> Verificando estructura creada..." -ForegroundColor Green
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Empresa,DC=redes2,DC=local" | Select-Object Name, DistinguishedName
Get-ADGroup -Filter * -SearchBase "OU=Empresa,DC=redes2,DC=local" | Select-Object Name
Get-ADUser -Filter * -SearchBase "OU=Empresa,DC=redes2,DC=local" | Select-Object Name, SamAccountName, Enabled

Write-Host ">>> Estructura de Active Directory completada con éxito." -ForegroundColor Green
