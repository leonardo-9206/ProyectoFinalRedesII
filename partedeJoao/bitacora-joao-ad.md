# Bitácora Técnica de Implementación — Windows Server & Active Directory (DC01)

- **Responsable:** Joao
- **Rol:** Administrador de Active Directory & Servicios de Dominio
- **Servidor:** `DC01` (`dc01.redes2.local`)
- **IP Estática:** `192.168.50.10/24` (Red Interna `intnet-redes2`)
- **Dominio:** `redes2.local` (NetBIOS: `REDES2`)

---

## Registro de Procedimientos Técnicos (8 Puntos Rúbrica)

### Estado General del Módulo:
- [x] Creación de VM `DC01` en VirtualBox con Red Interna `intnet-redes2`.
- [x] Instalación de Windows Server 2025 Standard (Desktop Experience).
- [x] Configuración de IP estática (`192.168.50.10`) y Hostname (`DC01`).
- [x] Snapshot `01-OS-Base`.
- [x] Instalación de rol AD DS y DNS Server.
- [x] Promoción a Controlador de Dominio (Nuevo bosque `redes2.local`).
- [x] Configuración y verificación de Zonas DNS (Directa e Inversa).
- [x] Habilitación de regla ICMPv4 en Firewall de Windows.
- [x] Creación de Unidades Organizativas (OUs), Grupos de Seguridad y Usuarios con PowerShell.
- [x] Verificación de autenticación y servicios de AD.
- [x] Snapshot `02-AD-Listo`.

---

## Procedimiento 1: Instalación base de Windows Server 2025, red estática y Snapshot `01-OS-Base`

### 1. Nombre y propósito del procedimiento
**Despliegue del sistema operativo Windows Server 2025 Standard (Desktop Experience) y configuración de red base en `DC01`.**
Preparar el servidor controlador de dominio con direccionamiento IP estático en la red interna `intnet-redes2`, zona horaria sincronizada para Kerberos (`UTC-06:00`) y punto de restauración base (`01-OS-Base`).

### 2. Requisitos previos
- Máquina virtual `DC01` creada en VirtualBox (`4 GB` RAM, `2 vCPU`, disco VDI de `40 GB`, Adaptador 1 en `intnet-redes2`, Adaptador 2 en `NAT`).
- Imagen ISO oficial `B:\ISOs\WinServer2025.iso` y `VBoxGuestAdditions.iso`.

### 3. Pasos realizados en orden cronológico
1. Ajuste de firmware de `DC01` a BIOS estándar y configuración de plantilla desatendida con particionamiento de dos volúmenes (`System Reserved` 500 MB + `Windows` NTFS).
2. Instalación desatendida de **Windows Server 2025 Standard Evaluation (Desktop Experience)** con hostname `DC01`, zona horaria `Central Standard Time (Mexico)` (`UTC-06:00`) y VirtualBox Guest Additions `7.2.0`.
3. Identificación por dirección MAC del adaptador conectado a `intnet-redes2` (`Ethernet 2`, MAC `08-00-27-07-CF-F3`) y del adaptador `NAT` (`Ethernet`, MAC `08-00-27-2F-61-AB`).
4. Asignación de IP estática `192.168.50.10/24` (sin puerta de enlace) y DNS `127.0.0.1` en `Ethernet 2` con métrica prioritaria `10`, y configuración de DNS `192.168.50.10` con métrica `500` en `Ethernet` para evitar fugas de resolución.
5. Creación del snapshot en VirtualBox: `01-OS-Base`.

### 4. Comandos utilizados y explicación de su propósito
- `New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress 192.168.50.10 -PrefixLength 24`: Asigna la dirección IPv4 estática del controlador de dominio en la red interna `intnet-redes2`.
- `Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses ("192.168.50.10","127.0.0.1")`: Configura al propio servidor como resolutor DNS primario.
- `Set-NetIPInterface -InterfaceAlias "Ethernet 2" -InterfaceMetric 10`: Prioriza la interfaz interna del dominio sobre el adaptador NAT (`InterfaceMetric 500`).
- `VBoxManage snapshot DC01 take "01-OS-Base"`: Crea el punto de recuperación base del sistema operativo.

### 5. Archivos de configuración modificados
- Configuración de red de Windows (`Ethernet 2` e `Ethernet` en el registro de interfaces de `DC01`).
- `B:\VMs\ProyectoFinalRedes\DC01\DC01.vbox` (parámetros de arranque BIOS y almacenamiento de snapshots).

### 6. Capturas de pantalla
- `Figura 1 — evidencias/01-ad/01-hostname-ip.png`: Salida de `hostname` e `ipconfig` mostrando `DC01` y `192.168.50.10`.

### 7. Pruebas realizadas para comprobar el funcionamiento
- Ejecución de `hostname` (resultado: `DC01`), `(Get-TimeZone).Id` (resultado: `Central Standard Time (Mexico)`) y `Get-NetIPAddress -InterfaceAlias "Ethernet 2" -AddressFamily IPv4` (resultado: `192.168.50.10/24`).

### 8. Problemas encontrados y soluciones aplicadas
- **Problema 1 — Congelamiento en arranque EFI de VirtualBox:** Con firmware EFI, la VM `DC01` quedaba detenida en `PciHostBridgeDxe.efi` antes de inicializar video (`VideoMode=0x0`).
  - **Solución:** Se cambió el firmware de `DC01` a BIOS (`VBoxManage modifyvm DC01 --firmware bios --tpm-type none`).
- **Problema 2 — Error de particionamiento en plantilla desatendida BIOS:** La plantilla predeterminada de VirtualBox creaba la partición sin formatearla en NTFS ni crear la partición `System Reserved`, deteniendo el instalador.
  - **Solución:** Se personalizó la plantilla XML con `<CreatePartitions>` de 2 particiones (`500 MB` activa + partición `Windows` extendida) y `<ModifyPartitions>` con `<Format>NTFS</Format>`.
- **Problema 3 — Bloqueo de snapshot en vivo (`--live`):** El snapshot en caliente detuvo la sesión de VirtualBox.
  - **Solución:** Se tomó el snapshot `01-OS-Base` con la VM apagada (`VBoxManage snapshot DC01 take "01-OS-Base"`), completándose de inmediato.

---

## Procedimiento 2: Instalación de roles AD DS / DNS y promoción del bosque `redes2.local`

### 1. Nombre y propósito del procedimiento
**Instalación de los roles Active Directory Domain Services (AD DS) y DNS Server, y promoción de `DC01` a Controlador de Dominio.**
Establecer el bosque y dominio raíz `redes2.local` (NetBIOS `REDES2`) con servidor DNS integrado para centralizar la autenticación Kerberos/LDAP de los equipos Windows y Linux.

### 2. Requisitos previos
- Sistema operativo base configurado con IP estática `192.168.50.10/24` y snapshot `01-OS-Base`.

### 3. Pasos realizados en orden cronológico
1. Instalación de las características `AD-Domain-Services` y `DNS` con sus herramientas de administración (`RSAT`).
2. Promoción de `DC01` como Controlador de Dominio de un nuevo bosque (`redes2.local`, NetBIOS `REDES2`) con DNS y Catálogo Global (`GC`) habilitados.
3. Reinicio del servidor para completar la inicialización de los servicios de Active Directory (`ADWS`, `DNS`, `Kdc`, `Netlogon`).

### 4. Comandos utilizados y explicación de su propósito
- `Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools`: Instala los binarios y consolas de administración de AD DS y DNS Server.
- `Install-ADDSForest -DomainName "redes2.local" -DomainNetbiosName "REDES2" -SafeModeAdministratorPassword $secPass -InstallDns:$true -Force:$true`: Promueve el servidor a Controlador de Dominio raíz del nuevo bosque `redes2.local`.

### 5. Archivos de configuración modificados
- Base de datos de Active Directory (`C:\Windows\NTDS\ntds.dit`) y carpeta compartida `SYSVOL` (`C:\Windows\SYSVOL`).

### 6. Capturas de pantalla
- `Figura 2 — evidencias/01-ad/02-instalacion-adds.png`: Estado `Installed` de `AD-Domain-Services` y `DNS`.
- `Figura 3 — evidencias/01-ad/03-promocion-dc.png`: Propiedades del dominio `redes2.local` y del Controlador de Dominio `DC01`.

### 7. Pruebas realizadas para comprobar el funcionamiento
- Validación de `Get-Service ADWS, DNS, Kdc, Netlogon` (todos en estado `Running`) y `Get-ADDomain` confirmando `DNSRoot: redes2.local` y `NetBIOSName: REDES2`.

### 8. Problemas encontrados y soluciones aplicadas
- **Problema — Dirección de enlace tras promoción:** Al reiniciar tras la promoción, la interfaz `Ethernet 2` requería reafirmar la IP estática `192.168.50.10` y reiniciar `DNS`, `Netlogon` y `ADWS` para enlazar correctamente los servicios de dominio.
  - **Solución:** Se reasignó `192.168.50.10/24` y se reiniciaron los servicios `DNS`, `Netlogon` y `ADWS`.

---

## Procedimiento 3: Configuración de DNS (Zona Inversa), Firewall y Estructura de Active Directory

### 1. Nombre y propósito del procedimiento
**Configuración de zona DNS inversa `50.168.192.in-addr.arpa`, habilitación de ICMPv4 en Firewall y creación de OUs, grupos de seguridad y usuarios de laboratorio.**
Garantizar la resolución directa e inversa para clientes Windows y Linux (`realmd`/`sssd`), permitir pruebas de conectividad `ping` y aprovisionar la estructura organizativa definida en `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md`.

### 2. Requisitos previos
- `DC01` promovido como Controlador de Dominio de `redes2.local` con servicios `ADWS`, `DNS`, `Kdc` y `Netlogon` en ejecución.

### 3. Pasos realizados en orden cronológico
1. Deshabilitación del registro DNS en el adaptador `NAT` (`Ethernet`) y eliminación de registros A/AAAA ajenos (`10.0.3.15` e IPv6) en la zona `redes2.local` para asegurar que el dominio resuelva únicamente a `192.168.50.10`.
2. Creación de la zona de búsqueda inversa `50.168.192.in-addr.arpa` y del registro `PTR` `10` → `dc01.redes2.local`.
3. Habilitación de la regla de firewall `File and Printer Sharing (Echo Request - ICMPv4-In)` para permitir respuestas `ping`.
4. Creación de las 5 Unidades Organizativas (`Empresa`, `TI`, `Desarrollo`, `Administracion`, `Equipos`), los 4 grupos globales de seguridad (`GRP_TI`, `GRP_LinuxAdmins`, `GRP_Desarrollo`, `GRP_Administracion`) y los 5 usuarios del equipo (`joao.admin`, `josh.user`, `rodri.dev`, `leo.dev`, `antonio.ti`) con contraseña `Redes2026!`.
5. Asignación de membresías de grupo y creación del snapshot final del módulo `02-AD-Listo`.

### 4. Comandos utilizados y explicación de su propósito
- `Set-DnsClient -InterfaceAlias "Ethernet" -RegisterThisConnectionsAddress $false`: Evita que la IP `10.0.3.15` de NAT se registre en el DNS del dominio.
- `Add-DnsServerPrimaryZone -NetworkID "192.168.50.0/24" -ZoneFile "50.168.192.in-addr.arpa.dns" -DynamicUpdate NonsecureAndSecure`: Crea la zona de búsqueda inversa para la subred `192.168.50.0/24`.
- `Add-DnsServerResourceRecordPtr -ZoneName "50.168.192.in-addr.arpa" -Name "10" -PtrDomainName "dc01.redes2.local"`: Crea el registro PTR inverso para `DC01`.
- `Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"`: Permite solicitudes ICMP Echo (ping) en el Firewall de Windows.
- `New-ADOrganizationalUnit`, `New-ADGroup`, `New-ADUser`, `Add-ADGroupMember` (equivalentes a `scripts/01-setup-ad-structure.ps1`): Crean la estructura jerárquica completa de Active Directory.

### 5. Archivos de configuración modificados
- Zonas DNS en `DC01`: `redes2.local` y `C:\Windows\System32\dns\50.168.192.in-addr.arpa.dns`.
- Base de datos de Active Directory (`OU=Empresa,DC=redes2,DC=local`).

### 6. Capturas de pantalla
- `Figura 4 — evidencias/01-ad/03-promocion-dc.png`: Información del bosque y controlador de dominio `redes2.local`.
- `Figura 5 — evidencias/01-ad/04-dns-zonas.png`: Zonas DNS directa (`redes2.local`) e inversa (`50.168.192.in-addr.arpa`) y resolución `nslookup`.
- `Figura 6 — evidencias/01-ad/05-ad-ous-usuarios.png`: Árbol de OUs, grupos de seguridad y los 5 usuarios en Active Directory.
- `Figura 7 — evidencias/01-ad/06-verificacion-ad.png`: Estado de servicios `ADWS`, `DNS`, `Kdc`, `Netlogon` y resolución `nslookup redes2.local 192.168.50.10`.

### 7. Pruebas realizadas para comprobar el funcionamiento
- `nslookup redes2.local 192.168.50.10` → resolvió exclusivamente `192.168.50.10`.
- `nslookup 192.168.50.10 192.168.50.10` → resolvió `dc01.redes2.local`.
- `Get-ADOrganizationalUnit`, `Get-ADGroup`, `Get-ADUser` → confirmaron las 5 OUs, 4 grupos y 5 usuarios habilitados (`Enabled: True`).

### 8. Problemas encontrados y soluciones aplicadas
- **Problema — Error `WIN32 9901` al crear zona inversa integrada en AD:** El comando `Add-DnsServerPrimaryZone` con `-ReplicationScope "Domain"` arrojó `WIN32 9901` porque la partición `DomainDnsZones` aún no respondía tras el primer arranque.
  - **Solución:** Se creó la zona inversa como zona primaria basada en archivo (`-ZoneFile "50.168.192.in-addr.arpa.dns" -DynamicUpdate NonsecureAndSecure`) y se agregó el registro `PTR` de `192.168.50.10` a `dc01.redes2.local`, validando con `nslookup`.
