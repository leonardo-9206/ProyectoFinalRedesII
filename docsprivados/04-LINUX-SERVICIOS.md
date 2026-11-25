# 04 — Servidor Linux: 3 Servicios de Red (SRV-LINUX01)

- **Responsable:** Leo
- **Peso en rúbrica:** Parte 2 del 30% de Linux
- **Prerrequisito:** Haber leído `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` y que `SRV-LINUX01` tenga el Snapshot **`04-Linux-Unido-AD`** funcionando (login AD comprobado por Rodri).

---

## 1. Objetivo del Módulo

Instalar, configurar, documentar y probar **3 servicios de red** en `SRV-LINUX01` (`192.168.50.30`), demostrando su operación e **interoperabilidad con cuentas de Active Directory** desde el Cliente Windows (`WIN-CLI01`):
1. **Servicio 1: Servidor Web (`Nginx`)** — Accesible por DNS (`http://srv-linux01.redes2.local`).
2. **Servicio 2: Servidor de Archivos (`Samba`)** — Recurso compartido accesible desde el Explorador de Windows con usuarios del dominio (`leo.dev` / `GRP_Desarrollo`).
3. **Servicio 3: Servidor FTP (`vsftpd`)** — Transferencia de archivos autenticada con usuarios de Active Directory (vía PAM/SSSD).

> **NOTA IMPORTANTE:** Antes de empezar, confirmar que existe el Snapshot `04-Linux-Unido-AD` en VirtualBox. Si en cualquier paso algo rompe el login de AD, se puede regresar a ese snapshot en segundos.

---

## 2. Servicio 1 — Servidor Web (`Nginx`)

**Justificación:** Provee publicación de aplicaciones y sitios web internos en la red corporativa, permitiendo validar además la resolución DNS entre Windows y Linux.

### Instalación y configuración
```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx
```

Crear una página institucional del proyecto en `/var/www/html/index.html`:
```bash
sudo tee /var/www/html/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Proyecto Final Redes 2 — SRV-LINUX01</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 760px; margin: 40px auto; padding: 20px; background: #f4f6f9; color: #222; }
    .card { background: #fff; padding: 24px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    h1 { color: #0f4c81; }
    .ok { color: #1b7f3a; font-weight: bold; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Infraestructura Integrada Active Directory + Linux</h1>
    <p><strong>Servidor:</strong> srv-linux01.redes2.local (192.168.50.30)</p>
    <p><strong>Dominio:</strong> redes2.local</p>
    <p><strong>Estado del Servicio Web (Nginx):</strong> <span class="ok">OPERATIVO</span></p>
    <p><strong>Equipo:</strong> Joao, Joshua, Rodrigo, Leonardo y Antonio</p>
  </div>
</body>
</html>
```

Permitir tráfico HTTP en el firewall (si `ufw` está activo):
```bash
sudo ufw allow 'Nginx HTTP'
```

### Prueba desde `WIN-CLI01`
1. Abrir el navegador (Edge/Chrome) en `WIN-CLI01` y entrar a:
   - `http://srv-linux01.redes2.local`
   - `http://192.168.50.30`
2. También comprobar desde PowerShell en `WIN-CLI01`:
   ```powershell
   Invoke-WebRequest http://srv-linux01.redes2.local | Select-Object StatusCode
   ```

---

## 3. Servicio 2 — Servidor de Archivos (`Samba`)

**Justificación:** Permite compartir archivos en red de forma transparente entre servidores Linux y clientes Windows mediante el protocolo SMB/CIFS, centralizando permisos por grupos de Active Directory.

> **NOTA TÉCNICA IMPORTANTE (SSSD vs Winbind):**
> En Ubuntu 22.04/24.04, `realmd` + `sssd` maneja el login del sistema (SSH, consola, PAM/FTP), mientras que Samba moderno usa `winbind` para validar credenciales SMB cuando `security = ads`.
> **NO modificar `/etc/nsswitch.conf` para quitar `sss`** (dejar `sss` intacto para no romper el login de Rodri).

### Instalación y configuración
1. Instalar Samba y Winbind:
   ```bash
   sudo apt install -y samba winbind libpam-winbind libnss-winbind
   ```
2. Crear el directorio compartido y asignar permisos al grupo de AD `GRP_Desarrollo`:
   ```bash
   sudo mkdir -p /srv/samba/compartido
   sudo chown -R root:"GRP_Desarrollo" /srv/samba/compartido
   sudo chmod -R 2775 /srv/samba/compartido
   ```
   *(Verificar que `getent group GRP_Desarrollo` devuelva el grupo antes de ejecutar `chown`).*
3. Respaldar y editar `/etc/samba/smb.conf`:
   ```bash
   sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
   ```
   Contenido de `/etc/samba/smb.conf`:
   ```ini
   [global]
      workgroup = REDES2
      realm = REDES2.LOCAL
      security = ads
      kerberos method = secrets and keytab
      dedicated keytab file = /etc/krb5.keytab
      winbind use default domain = yes
      winbind refresh tickets = yes

      idmap config * : backend = tdb
      idmap config * : range = 3000-7999
      idmap config REDES2 : backend = rid
      idmap config REDES2 : range = 10000-999999

      log file = /var/log/samba/log.%m
      max log size = 1000

   [compartido]
      comment = Carpeta Compartida del Dominio REDES2
      path = /srv/samba/compartido
      browseable = yes
      read only = no
      valid users = @"GRP_Desarrollo", @"GRP_TI"
      force group = "GRP_Desarrollo"
      create mask = 0664
      directory mask = 2775
   ```
4. Validar sintaxis, registrar secrets de Samba con AD (si es necesario) y reiniciar servicios:
   ```bash
   testparm -s
   sudo systemctl enable --now smbd nmbd winbind
   sudo systemctl restart smbd winbind
   sudo systemctl status smbd winbind
   ```
   *(Si Samba pide unir secrets para winbind: `sudo net ads join -U Administrator` — sin tocar `sssd.conf` — y luego reiniciar `smbd`, `winbind` y `sssd`).*
5. Si `ufw` está activo:
   ```bash
   sudo ufw allow Samba
   ```

> **Plan B limpio (si `winbind` llegara a dar lata en laboratorio):**
> Si por tiempo en pruebas `winbind` rechazara SMB, NO te bloquees: usa Samba en `security = user` creando usuarios espejo (`sudo smbpasswd -a leo.dev`) mapeados al mismo usuario de AD que ya resuelve SSSD, documentando el porqué en "Problemas encontrados y soluciones". Sin embargo, intenta primero la configuración `security = ads` de arriba porque es la más profesional.

### Prueba desde `WIN-CLI01`
1. En `WIN-CLI01` (sesión iniciada con `leo.dev` o `joao.admin`), presionar `Win + R` y escribir:
   ```text
   \\srv-linux01.redes2.local\compartido
   ```
2. Crear un archivo de texto `prueba-windows.txt` dentro de la carpeta compartida.
3. En `SRV-LINUX01`, comprobar que el archivo existe y tiene propietario del dominio:
   ```bash
   ls -la /srv/samba/compartido
   ```

---

## 4. Servicio 3 — Servidor FTP (`vsftpd`) autenticado con AD

**Justificación:** Permite la transferencia estandarizada de archivos entre clientes y servidores de red aprovechando la autenticación centralizada de Active Directory a través de PAM/SSSD.

### Instalación y configuración
1. Instalar `vsftpd`:
   ```bash
   sudo apt install -y vsftpd
   sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
   ```
2. Editar `/etc/vsftpd.conf` asegurando estas directivas clave:
   ```ini
   listen=YES
   listen_ipv6=NO
   anonymous_enable=NO
   local_enable=YES
   write_enable=YES
   local_umask=022
   dirmessage_enable=YES
   use_localtime=YES
   xferlog_enable=YES
   connect_from_port_20=YES
   chroot_local_user=YES
   allow_writeable_chroot=YES
   pam_service_name=vsftpd
   pasv_enable=YES
   pasv_min_port=40000
   pasv_max_port=40100
   ```
3. Verificar que `/etc/pam.d/vsftpd` permita usuarios autenticados vía PAM/SSSD (por defecto incluye `@include common-auth`, `@include common-account`, `@include common-session`; revisar si tiene `pam_shells.so` — si da error de login con usuarios AD, verificar que `/bin/bash` esté en `/etc/shells`).
4. Reiniciar y verificar `vsftpd`:
   ```bash
   sudo systemctl enable --now vsftpd
   sudo systemctl restart vsftpd
   sudo systemctl status vsftpd
   ```
5. Si `ufw` está activo:
   ```bash
   sudo ufw allow 20/tcp
   sudo ufw allow 21/tcp
   sudo ufw allow 40000:40100/tcp
   ```

### Prueba desde `WIN-CLI01`
1. En `WIN-CLI01`, abrir PowerShell o CMD (o FileZilla si se instaló):
   ```powershell
   ftp srv-linux01.redes2.local
   ```
2. Iniciar sesión con `leo.dev` y contraseña `Redes2026!`.
3. Ejecutar dentro de FTP:
   ```text
   pwd
   ls
   put C:\Users\Public\prueba-ftp.txt
   ls
   quit
   ```
4. En `SRV-LINUX01`, comprobar que `prueba-ftp.txt` apareció en `/home/leo.dev@redes2.local/`.

---

## 5. Verificación Final de Puertos y Snapshot

1. Comprobar que los 3 servicios (+ SSH) están escuchando en `SRV-LINUX01`:
   ```bash
   sudo ss -tulpn | grep -E ':(21|22|80|139|445)\b'
   sudo systemctl status nginx smbd vsftpd sssd --no-pager
   ```
2. **Tomar Snapshot en VirtualBox (en las 3 VMs):** `05-DEMO-FINAL` (una vez que Antonio valide las pruebas end-to-end offline).

---

## 6. Recordatorio de Bitácora (para tu parte del reporte)

> **IMPORTANTE:** Mientras configuras Nginx, Samba y vsftpd, ve guardando en una nota rápida: (1) los archivos modificados (`index.html`, `smb.conf`, `vsftpd.conf`), (2) **qué errores te salieron y cómo los resolviste**, y (3) tus capturas numeradas. Al terminar, pásale esa nota a tu agente de IA junto con `docsprivados/05-RED-PRUEBAS-Y-DOCUMENTO.md` para que te redacte tu sección con los 8 puntos obligatorios de la rúbrica.

## 7. Checklist de Capturas Obligatorias (guardar en `evidencias/04-linux-servicios/`)

- [ ] `01-nginx-status.png`: `systemctl status nginx` y archivo `/var/www/html/index.html`.
- [ ] `02-nginx-prueba-win.png`: Navegador en `WIN-CLI01` mostrando la página en `http://srv-linux01.redes2.local`.
- [ ] `03-samba-config.png`: `testparm -s` y `systemctl status smbd`.
- [ ] `04-samba-prueba-win.png`: Explorador de Windows en `WIN-CLI01` accediendo a `\\srv-linux01.redes2.local\compartido` con un archivo creado + `ls -la /srv/samba/compartido` en Linux.
- [ ] `05-vsftpd-config.png`: Configuración de `/etc/vsftpd.conf` y `systemctl status vsftpd`.
- [ ] `06-vsftpd-prueba-win.png`: Conexión FTP desde `WIN-CLI01` autenticado con `leo.dev` subiendo un archivo (`put`) y listándolo (`ls`).
- [ ] `07-puertos-servicios.png`: Salida de `ss -tulpn` mostrando puertos 21, 22, 80 y 445 activos.

---

## 7. Problemas Comunes y Soluciones

- **Windows no abre `\\srv-linux01.redes2.local\compartido`:** Verificar firewall (`ufw`), verificar que `srv-linux01.redes2.local` resuelva en DNS, y probar primero por IP (`\\192.168.50.30\compartido`).
- **FTP devuelve `530 Login incorrect` con usuario AD:** Revisar que el usuario ya tenga home creado (iniciando sesión una vez por SSH o asegurando `pam_mkhomedir` en `/etc/pam.d/common-session`) y que `use_fully_qualified_names = False` esté activo en `sssd.conf`.
- **FTP devuelve `500 OOPS: vsftpd: refusing to run with writable root inside chroot()`:** Asegurar `allow_writeable_chroot=YES` en `/etc/vsftpd.conf` y reiniciar `vsftpd`.
