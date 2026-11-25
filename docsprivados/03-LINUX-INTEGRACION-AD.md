# 03 — Servidor Linux: Instalación e Integración a Active Directory (SRV-LINUX01)

- **Responsable:** Rodri
- **Peso en rúbrica:** Parte 1 del 30% de Linux (la parte más crítica técnicamente)
- **Prerrequisito:** Haber leído `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` y tener `DC01` activo (`02-AD-Listo`).
- **Referencia oficial del docente:** [Red Hat — How to join a Linux system to an Active Directory domain](https://www.redhat.com/en/blog/linux-active-directory)

---

## 1. Objetivo del Módulo

Instalar **Ubuntu Server 22.04 LTS o 24.04 LTS** (`SRV-LINUX01`), configurar su red estática y DNS apuntando a `DC01`, sincronizar el reloj (NTP), unir el servidor al dominio `redes2.local` mediante **`realmd` + `sssd` + `Kerberos`**, restringir el acceso por grupos de AD (`realm permit`), y comprobar que los usuarios autorizados de Active Directory (`rodri.dev`, `leo.dev`, `joao.admin`) pueden iniciar sesión en Linux por consola y por SSH.

---

## 2. Datos Exactos de Configuración

- **Sistema Operativo:** Ubuntu Server 22.04 LTS o 24.04 LTS (sin interfaz gráfica para ahorrar RAM).
- **Hostname / FQDN:** `srv-linux01.redes2.local`
- **Adaptador 1 (`intnet-redes2`):**
  - IP: `192.168.50.30/24`
  - DNS: `192.168.50.10`
  - Dominio de búsqueda (`search`): `redes2.local`
- **Adaptador 2 (`NAT`):** Solo para instalar paquetes con `apt`. **Asegurarse de que su DHCP NO sobrescriba el DNS del dominio (`use-dns: false`).**
- **Zona horaria:** `America/Mexico_City`.

---

## 3. Procedimiento Paso a Paso

### Paso 1: Instalación base, hostname y zona horaria
1. Crear VM en VirtualBox (2 GB RAM, 2 vCPU, 25 GB disco, Adaptador 1: Red Interna `intnet-redes2`, Adaptador 2: NAT).
2. Instalar Ubuntu Server (habilitar **OpenSSH Server** durante el instalador). Crear usuario local administrativo (ej. `ubuntuadmin`).
3. Configurar hostname FQDN y zona horaria:
   ```bash
   sudo hostnamectl set-hostname srv-linux01.redes2.local
   sudo timedatectl set-timezone America/Mexico_City
   timedatectl
   ```

### Paso 2: Configuración de red estática y DNS con Netplan
1. Revisar los nombres de las interfaces con `ip a` (usualmente `enp0s3` es Adaptador 1 / Red Interna y `enp0s8` es Adaptador 2 / NAT).
2. Editar `/etc/netplan/00-installer-config.yaml` (o el archivo `.yaml` existente en `/etc/netplan/`):
   ```yaml
   network:
     version: 2
     ethernets:
       enp0s3:
         dhcp4: false
         addresses:
           - 192.168.50.30/24
         nameservers:
           addresses:
             - 192.168.50.10
           search:
             - redes2.local
       enp0s8:
         dhcp4: true
         dhcp4-overrides:
           use-dns: false
   ```
   > **CRÍTICO:** `use-dns: false` en `enp0s8` evita que VirtualBox NAT ponga el DNS de tu casa y rompa la resolución de `redes2.local`. *(Si necesitas internet temporalmente para `apt` y `DC01` no tiene forwarder a internet, puedes poner temporalmente `8.8.8.8` mientras haces `apt install` y luego quitarlo antes de unirte al dominio).*
3. Aplicar y probar conectividad + DNS:
   ```bash
   sudo netplan apply
   ip a
   ping -c 4 192.168.50.10
   resolvectl status
   dig redes2.local
   dig _ldap._tcp.redes2.local SRV
   ```
   *(El comando `dig` DEBE responder con `192.168.50.10` / `dc01.redes2.local`. Si no responde, no avanzar).*

### Paso 3: Sincronización de hora (NTP) con DC01
Kerberos falla si hay más de 5 minutos de diferencia con `DC01`.
```bash
sudo apt update
sudo apt install -y chrony
```
Editar `/etc/chrony/chrony.conf` y agregar al inicio:
```text
server 192.168.50.10 iburst
```
Reiniciar y comprobar:
```bash
sudo systemctl restart chrony
chronyc sources -v
date
```

### Paso 4: Instalar paquetes de integración con Active Directory
```bash
sudo apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli \
  samba-common-bin oddjob oddjob-mkhomedir packagekit krb5-user
```
*(Si aparece una pantalla azul pidiendo el "Default Kerberos realm", escribir en MAYÚSCULAS: `REDES2.LOCAL`).*

### Paso 5: Descubrir, unir al dominio y restringir acceso por grupos (Guía Red Hat)
1. Descubrir el dominio:
   ```bash
   sudo realm discover redes2.local
   ```
   *(Debe mostrar `domain-name: redes2.local`, `realm-name: REDES2.LOCAL`, `configured: no`).*
2. Unir el servidor al dominio ubicándolo directamente en `OU=Equipos` (buena práctica del blog oficial de Red Hat):
   ```bash
   sudo realm join -v -U Administrator redes2.local --computer-ou="OU=Equipos,OU=Empresa,DC=redes2,DC=local"
   ```
   *(Ingresar la contraseña de Administrator de `DC01`. Si llegara a dar error por ruta de OU, ejecutar sin `--computer-ou` y mover el equipo después en `dsa.msc`).*
3. Verificar la unión:
   ```bash
   realm list
   ```
   *(Debe mostrar `configured: kerberos-member`).*
4. **Control de acceso por grupos de AD (`realm deny` / `realm permit`):**
   Restringir el inicio de sesión en Linux únicamente a `GRP_TI` y `GRP_Desarrollo`:
   ```bash
   sudo realm deny --all
   sudo realm permit -g GRP_TI GRP_Desarrollo
   realm list
   ```
   *(Esto permite demostrar en la exposición que `rodri.dev` y `leo.dev` SÍ entran a Linux, mientras que `josh.user` — que es de `GRP_Administracion` — es rechazado automáticamente).*

### Paso 6: Configurar SSSD y creación automática de directorios Home
1. Habilitar la creación automática del directorio `/home/<usuario>` al iniciar sesión por primera vez:
   ```bash
   sudo pam-auth-update --enable mkhomedir
   ```
2. Editar `/etc/sssd/sssd.conf` para simplificar el formato de usuario (poder escribir `rodri.dev` en vez de `rodri.dev@redes2.local`):
   ```ini
   [sssd]
   domains = redes2.local
   config_file_version = 2
   services = nss, pam

   [domain/redes2.local]
   default_shell = /bin/bash
   krb5_store_password_if_offline = True
   cache_credentials = True
   krb5_realm = REDES2.LOCAL
   realmd_tags = manages-system joined-with-adcli
   id_provider = ad
   fallback_homedir = /home/%u@%d
   ad_domain = redes2.local
   use_fully_qualified_names = False
   ldap_id_mapping = True
   access_provider = simple
   simple_allow_groups = GRP_TI, GRP_Desarrollo
   ```
   *(Nota: `realm permit -g` configura automáticamente `access_provider = simple` y `simple_allow_groups`; verifica que esos campos se conserven al editar `sssd.conf`).*
3. Asegurar permisos estrictos y reiniciar `sssd`:
   ```bash
   sudo chmod 600 /etc/sssd/sssd.conf
   sudo systemctl restart sssd
   sudo systemctl status sssd
   ```
4. Dar privilegios `sudo` al grupo `GRP_LinuxAdmins`:
   ```bash
   echo "%GRP_LinuxAdmins ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/ad-linux-admins
   sudo chmod 440 /etc/sudoers.d/ad-linux-admins
   ```
5. Verificar en `DC01` (con Joao) que:
   - En `dsa.msc` → `Empresa` → `Equipos` (o `Computers`) aparezca `SRV-LINUX01`.
   - En **DNS Manager** exista el registro `A` de `srv-linux01.redes2.local` → `192.168.50.30` (si no se registró automáticamente, crearlo manualmente junto con su `PTR` en zona inversa).

### Paso 7: Comprobar autenticación centralizada de usuarios AD
Ejecutar y capturar todas estas pruebas:
```bash
# 1. Resolver identidad de usuarios de AD
id rodri.dev
id leo.dev
getent passwd rodri.dev

# 2. Probar ticket Kerberos
kinit rodri.dev@REDES2.LOCAL
klist

# 3. Probar cambio de sesión local
su - rodri.dev
whoami
pwd
exit
```
**Prueba desde `WIN-CLI01` (por SSH en PowerShell):**
```powershell
# Prueba positiva (autorizado en GRP_Desarrollo):
ssh rodri.dev@srv-linux01.redes2.local

# Prueba negativa (NO autorizado — GRP_Administracion):
ssh josh.user@srv-linux01.redes2.local
```
*(Con `rodri.dev` debe pedir la contraseña `Redes2026!`, crear `/home/rodri.dev@redes2.local` y abrir el prompt; con `josh.user` debe denegar el acceso).*

### Paso 8: Snapshot Obligatorio
- **Tomar Snapshot en VirtualBox (`SRV-LINUX01`):** `04-Linux-Unido-AD`.
- **Avisar a Leo** para que despliegue los 3 servicios sobre este snapshot limpio.

---

## 4. Recordatorio de Bitácora (para tu parte del reporte)

> **IMPORTANTE:** Mientras haces estos pasos, ve guardando en una nota rápida: (1) los comandos que ejecutaste y copias de `/etc/netplan/*.yaml` y `/etc/sssd/sssd.conf`, (2) **qué errores te salieron y cómo los resolviste**, y (3) tus capturas numeradas. Al terminar, pásale esa nota a tu agente de IA junto con `docsprivados/05-RED-PRUEBAS-Y-DOCUMENTO.md` para que te redacte tu sección con los 8 puntos obligatorios de la rúbrica.

## 5. Checklist de Capturas Obligatorias (guardar en `evidencias/03-linux-ad/`)

- [ ] `01-hostname-netplan-ip.png`: Salida de `hostnamectl`, `ip a` y archivo `/etc/netplan/*.yaml`.
- [ ] `02-dns-ntp.png`: Salida de `dig redes2.local`, `dig _ldap._tcp.redes2.local SRV` y `timedatectl` / `chronyc sources`.
- [ ] `03-realm-discover-join.png`: Salida de `realm discover redes2.local`, `realm join -v`, `realm permit -g` y `realm list`.
- [ ] `04-sssd-conf.png`: Contenido de `/etc/sssd/sssd.conf` y `systemctl status sssd`.
- [ ] `05-id-kerberos.png`: Salida de `id rodri.dev`, `kinit` y `klist`.
- [ ] `06-login-ssh-ad.png`: Inicio de sesión SSH desde `WIN-CLI01` hacia `srv-linux01.redes2.local` con `rodri.dev` (exitoso) y prueba negativa con `josh.user` (denegado).
- [ ] `07-ad-computer-object.png`: Objeto `SRV-LINUX01` visible en Active Directory (`dsa.msc`) en `DC01`.

---

## 5. Problemas Comunes y Soluciones

- **`Couldn't find realm`:** El DNS no está apuntando a `192.168.50.10` o el adaptador NAT sobrescribió `/etc/resolv.conf`. Revisar `resolvectl status`.
- **`Clock skew too great`:** Desfase de hora con `DC01`. Sincronizar con `chrony` o ajustar manualmente con `sudo timedatectl`.
- **`id rodri.dev` no devuelve nada tras editar `sssd.conf`:** Limpiar caché de SSSD y reiniciar:
  ```bash
  sudo systemctl stop sssd
  sudo rm -rf /var/lib/sss/db/*
  sudo systemctl start sssd
  ```
- **Error de permiso al iniciar sesión por SSH:** Verificar que `PasswordAuthentication yes` esté habilitado en `/etc/ssh/sshd_config` (y en `/etc/ssh/sshd_config.d/*.conf`).
