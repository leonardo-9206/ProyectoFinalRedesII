# 01 — Windows Server & Active Directory (DC01)

- **Responsable:** Joao
- **Peso en rúbrica:** 10% (base obligatoria para todo el resto del proyecto)
- **Prerrequisito:** Haber leído `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md`.

---

## 1. Objetivo del Módulo

Instalar y configurar `DC01` (Windows Server 2022 Desktop Experience) como **Controlador de Dominio** del dominio `redes2.local`, con **AD DS** y **DNS** funcionando correctamente, y crear las Unidades Organizativas (OUs), grupos de seguridad y usuarios acordados por el equipo.

---

## 2. Datos Exactos de Configuración

- **Nombre del equipo (Hostname):** `DC01`
- **Dominio (FQDN):** `redes2.local`
- **Nombre NetBIOS:** `REDES2`
- **Adaptador 1 (`intnet-redes2`):**
  - IP: `192.168.50.10`
  - Máscara: `255.255.255.0`
  - Puerta de enlace: *(dejar vacío)*
  - DNS Preferido: `127.0.0.1` (después de promover AD, validar que quede `192.168.50.10` y/o `127.0.0.1`)
- **Adaptador 2:** `NAT` (solo si se requiere descargar algo; desactivar su DNS o desconectarlo tras instalar).
- **Zona horaria:** `(UTC-06:00) Guadalajara, Ciudad de México, Monterrey`.

---

## 3. Procedimiento Paso a Paso

### Paso 1: Instalación base y configuración inicial
1. Crear VM en VirtualBox (4 GB RAM, 2 vCPU, 40 GB disco, Adaptador 1: Red Interna `intnet-redes2`).
2. Instalar **Windows Server 2022 Standard/Datacenter (Desktop Experience)**.
3. Configurar la zona horaria a `UTC-06:00` y validar fecha y hora exactas.
4. Cambiar el nombre del equipo a `DC01` y reiniciar:
   ```powershell
   Rename-Computer -NewName "DC01" -Restart
   ```
5. Configurar IP estática en el adaptador de Red Interna (por interfaz gráfica en `ncpa.cpl` o por PowerShell):
   ```powershell
   # Ver nombre de la interfaz
   Get-NetAdapter
   # Configurar IP estática (ajustar InterfaceAlias si se llama Ethernet 2)
   New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.50.10 -PrefixLength 24
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
   ```
6. **Tomar Snapshot en VirtualBox:** `01-OS-Base`.

### Paso 2: Instalación del rol AD DS y DNS
1. Abrir **Server Manager** → *Add Roles and Features* (o por PowerShell):
   ```powershell
   Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
   ```
2. Promover el servidor a Controlador de Dominio (**Nuevo bosque / New Forest**):
   - Root domain name: `redes2.local`
   - NetBIOS name: `REDES2`
   - DNS Server y Global Catalog (GC): **marcados**.
   - Contraseña DSRM: anotar y guardar en lugar seguro.
   - *(Opcional vía PowerShell):*
     ```powershell
     Install-ADDSForest -DomainName "redes2.local" -DomainNetbiosName "REDES2" -InstallDns:$true -Force:$true
     ```
3. El servidor se reiniciará automáticamente. Iniciar sesión como `REDES2\Administrator`.

### Paso 3: Verificación y ajustes de DNS
1. Abrir **DNS Manager** (`dnsmgmt.msc`):
   - Verificar que exista la **Zona de búsqueda directa** `redes2.local` con el registro `A` de `dc01` → `192.168.50.10`.
   - Crear la **Zona de búsqueda inversa** para la subred `192.168.50` (`50.168.192.in-addr.arpa`) — ayuda a las pruebas de Antonio y a la resolución inversa de Linux.
   - Crear el registro `PTR` para `192.168.50.10` → `dc01.redes2.local`.
2. Verificar servicios y DNS desde PowerShell:
   ```powershell
   Get-Service ADWS, DNS, Kdc, Netlogon
   nslookup redes2.local 192.168.50.10
   dcdiag /test:dns
   ```
3. Permitir ICMP (ping) en el Firewall de Windows (perfil Dominio y Privado) para las pruebas de conectividad:
   ```powershell
   Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
   ```

### Paso 4: Creación de OUs, Grupos y Usuarios
Crear la estructura definida en `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` (se puede hacer en **Active Directory Users and Computers — `dsa.msc`** o con el siguiente script de PowerShell, tomando captura de ambos):

```powershell
# 1. Crear Unidades Organizativas
New-ADOrganizationalUnit -Name "Empresa" -Path "DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "TI" -Path "OU=Empresa,DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "Desarrollo" -Path "OU=Empresa,DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "Administracion" -Path "OU=Empresa,DC=redes2,DC=local"
New-ADOrganizationalUnit -Name "Equipos" -Path "OU=Empresa,DC=redes2,DC=local"

# 2. Crear Grupos de Seguridad
New-ADGroup -Name "GRP_TI" -GroupScope Global -GroupCategory Security -Path "OU=TI,OU=Empresa,DC=redes2,DC=local"
New-ADGroup -Name "GRP_LinuxAdmins" -GroupScope Global -GroupCategory Security -Path "OU=TI,OU=Empresa,DC=redes2,DC=local"
New-ADGroup -Name "GRP_Desarrollo" -GroupScope Global -GroupCategory Security -Path "OU=Desarrollo,OU=Empresa,DC=redes2,DC=local"
New-ADGroup -Name "GRP_Administracion" -GroupScope Global -GroupCategory Security -Path "OU=Administracion,OU=Empresa,DC=redes2,DC=local"

# 3. Crear Usuarios (contraseña de laboratorio: Redes2026!)
$pass = ConvertTo-SecureString "Redes2026!" -AsPlainText -Force

New-ADUser -Name "Joao Admin" -SamAccountName "joao.admin" -UserPrincipalName "joao.admin@redes2.local" `
  -Path "OU=TI,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

New-ADUser -Name "Joshua Cliente" -SamAccountName "josh.user" -UserPrincipalName "josh.user@redes2.local" `
  -Path "OU=Administracion,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

New-ADUser -Name "Rodrigo Linux" -SamAccountName "rodri.dev" -UserPrincipalName "rodri.dev@redes2.local" `
  -Path "OU=Desarrollo,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

New-ADUser -Name "Leonardo Servicios" -SamAccountName "leo.dev" -UserPrincipalName "leo.dev@redes2.local" `
  -Path "OU=Desarrollo,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

New-ADUser -Name "Antonio Redes" -SamAccountName "antonio.ti" -UserPrincipalName "antonio.ti@redes2.local" `
  -Path "OU=TI,OU=Empresa,DC=redes2,DC=local" -AccountPassword $pass -Enabled $true -PasswordNeverExpires $true

# 4. Asignar Usuarios a Grupos
Add-ADGroupMember -Identity "GRP_TI" -Members "joao.admin", "antonio.ti"
Add-ADGroupMember -Identity "GRP_LinuxAdmins" -Members "joao.admin"
Add-ADGroupMember -Identity "GRP_Desarrollo" -Members "rodri.dev", "leo.dev"
Add-ADGroupMember -Identity "GRP_Administracion" -Members "josh.user"
```

### Paso 5: Verificación y Snapshot
1. Validar usuarios y grupos:
   ```powershell
   Get-ADUser -Filter * -SearchBase "OU=Empresa,DC=redes2,DC=local" | Select Name, SamAccountName, Enabled
   Get-ADGroup -Filter * -SearchBase "OU=Empresa,DC=redes2,DC=local" | Select Name
   ```
2. **Tomar Snapshot en VirtualBox:** `02-AD-Listo`.

---

## 4. Recordatorio de Bitácora (para tu parte del reporte)

> **IMPORTANTE:** Mientras haces estos pasos, ve guardando en una nota rápida: (1) los comandos/pasos que sí ejecutaste, (2) **qué errores te salieron y cómo los resolviste**, y (3) tus capturas numeradas. Al terminar, pásale esa nota a tu agente de IA junto con `docsprivados/05-RED-PRUEBAS-Y-DOCUMENTO.md` para que te redacte tu sección con los 8 puntos obligatorios de la rúbrica.

## 5. Checklist de Capturas Obligatorias (guardar en `evidencias/01-ad/`)

- [ ] `01-hostname-ip.png`: Salida de `hostname` e `ipconfig /all` mostrando `DC01` y `192.168.50.10`.
- [ ] `02-instalacion-adds.png`: Instalación del rol AD DS y DNS completada.
- [ ] `03-promocion-dc.png`: Asistente o resultado de promoción a Controlador de Dominio (`redes2.local`).
- [ ] `04-dns-zonas.png`: Consola DNS Manager mostrando zona directa `redes2.local` y zona inversa `50.168.192.in-addr.arpa`.
- [ ] `05-ad-ous-usuarios.png`: Consola `dsa.msc` mostrando el árbol `Empresa` → `TI`, `Desarrollo`, `Administracion`, `Equipos`, grupos y los 5 usuarios.
- [ ] `06-verificacion-ad.png`: Salida de `Get-Service ADWS, DNS, Kdc` y `nslookup redes2.local 192.168.50.10`.

---

## 5. Problemas Comunes y Soluciones (Documentar los que te salgan)

- **El DNS vuelve a `127.0.0.1` después de promover:** Es normal; dejar `192.168.50.10` como preferido y `127.0.0.1` como alternativo.
- **Los clientes no resuelven `redes2.local`:** Revisar que `DC01` y los clientes estén en la misma Red Interna `intnet-redes2` y que el Firewall de Windows permita tráfico DNS (puerto 53 UDP/TCP) en el perfil de Dominio.
- **No responde ping desde otras VMs:** Habilitar la regla `ICMPv4-In` del firewall de Windows.
