# Bitácora Técnica — Módulo 04: Servicios de Red en Linux (`SRV-LINUX01`)

- **Integrante responsable:** Leonardo (Leo)
- **Servidor:** `SRV-LINUX01` (`srv-linux01.redes2.local` — `192.168.50.30`)
- **Dominio Active Directory:** `redes2.local` (`REDES2`)
- **Prerrequisito obligatorio:** Snapshot `04-Linux-Unido-AD` completado y validado por Rodri.

> Esta bitácora sigue exactamente los **8 requisitos obligatorios** de la sección 4.1 de `info.txt` para facilitar la redacción directa del Informe Técnico Académico en PDF (APA 7).

---

## Estado General del Módulo

- [x] **Fase 0 — Preparación previa:** Archivos de configuración base (`index.html`, `smb.conf`, `vsftpd.conf`) preparados en `configs/04-linux-servicios/` y cliente `ssh` verificado en Windows host.
- [ ] **Acceso remoto:** Tailscale instalado en host + conexión SSH probada hacia `SRV-LINUX01` en la Laptop Maestra.
- [ ] **Servicio 1 — Nginx:** Instalado, configurado, probado desde `WIN-CLI01` y capturado.
- [ ] **Servicio 2 — Samba:** Instalado, integrado con AD, probado desde `WIN-CLI01` y capturado.
- [ ] **Servicio 3 — vsftpd:** Instalado, autenticado con AD (PAM/SSSD), probado desde `WIN-CLI01` y capturado.
- [ ] **Verificación final y Snapshot:** Puertos verificados (`ss -tulpn`), pruebas offline con Antonio y Snapshot `05-DEMO-FINAL`.

---

## Procedimiento 1: Instalación y Configuración del Servidor Web (`Nginx`)

1. **Nombre y propósito del procedimiento:**
   Implementación del servidor web Nginx en `SRV-LINUX01` para publicar un portal web informativo interno de la infraestructura corporativa, comprobando la operación del servicio HTTP y la resolución DNS entre Windows y Linux.
2. **Requisitos previos:**
   - `SRV-LINUX01` unido al dominio `redes2.local` (Snapshot `04-Linux-Unido-AD`).
   - Registro DNS tipo `A` activo para `srv-linux01.redes2.local` → `192.168.50.30`.
   - Adaptador 2 (NAT) activo temporalmente para descarga de paquetes con `apt`.
3. **Pasos realizados en orden cronológico:**
   *(Pendiente de ejecución sobre `SRV-LINUX01`)*
4. **Comandos utilizados y explicación de su propósito:**
   *(Se registrarán conforme se ejecuten)*
5. **Archivos de configuración modificados:**
   - `/var/www/html/index.html` (plantilla preparada en `configs/04-linux-servicios/index.html`).
6. **Capturas de pantalla:**
   - [ ] `evidencias/04-linux-servicios/01-nginx-status.png` — Estado del servicio Nginx y contenido de `index.html`.
   - [ ] `evidencias/04-linux-servicios/02-nginx-prueba-win.png` — Acceso desde navegador en `WIN-CLI01` a `http://srv-linux01.redes2.local`.
7. **Pruebas realizadas para comprobar el funcionamiento:**
   *(Pendiente)*
8. **Problemas encontrados y soluciones aplicadas:**
   *(Pendiente)*

---

## Procedimiento 2: Instalación y Configuración del Servidor de Archivos (`Samba`) Integrado con Active Directory

1. **Nombre y propósito del procedimiento:**
   Implementación de un recurso compartido de red mediante Samba (`SMB/CIFS`) en `SRV-LINUX01` integrado con Active Directory (`security = ads`), permitiendo el intercambio de archivos con control de acceso por grupos de dominio (`GRP_Desarrollo` y `GRP_TI`) desde clientes Windows.
2. **Requisitos previos:**
   - `SRV-LINUX01` unido al dominio `redes2.local` con `sssd` y Kerberos operativos.
   - Grupos `GRP_Desarrollo` y `GRP_TI` visibles mediante `getent group`.
3. **Pasos realizados en orden cronológico:**
   *(Pendiente de ejecución sobre `SRV-LINUX01`)*
4. **Comandos utilizados y explicación de su propósito:**
   *(Se registrarán conforme se ejecuten)*
5. **Archivos de configuración modificados:**
   - `/etc/samba/smb.conf` (plantilla preparada en `configs/04-linux-servicios/smb.conf`).
6. **Capturas de pantalla:**
   - [ ] `evidencias/04-linux-servicios/03-samba-config.png` — Validación con `testparm -s` y estado de `smbd`.
   - [ ] `evidencias/04-linux-servicios/04-samba-prueba-win.png` — Acceso desde Explorador de Windows (`\\srv-linux01.redes2.local\compartido`) con archivo creado + `ls -la /srv/samba/compartido`.
7. **Pruebas realizadas para comprobar el funcionamiento:**
   *(Pendiente)*
8. **Problemas encontrados y soluciones aplicadas:**
   *(Pendiente)*

---

## Procedimiento 3: Instalación y Configuración del Servidor FTP (`vsftpd`) Autenticado con Active Directory

1. **Nombre y propósito del procedimiento:**
   Implementación del servidor FTP `vsftpd` en `SRV-LINUX01` aprovechando la autenticación centralizada de Active Directory vía `PAM/SSSD`, permitiendo a los usuarios del dominio (`leo.dev`, `rodri.dev`) transferir archivos desde `WIN-CLI01`.
2. **Requisitos previos:**
   - `SRV-LINUX01` unido al dominio `redes2.local` con `use_fully_qualified_names = False` en `sssd.conf` y `pam_mkhomedir` habilitado.
3. **Pasos realizados en orden cronológico:**
   *(Pendiente de ejecución sobre `SRV-LINUX01`)*
4. **Comandos utilizados y explicación de su propósito:**
   *(Se registrarán conforme se ejecuten)*
5. **Archivos de configuración modificados:**
   - `/etc/vsftpd.conf` (plantilla preparada en `configs/04-linux-servicios/vsftpd.conf`).
6. **Capturas de pantalla:**
   - [ ] `evidencias/04-linux-servicios/05-vsftpd-config.png` — Configuración de `/etc/vsftpd.conf` y estado de `vsftpd`.
   - [ ] `evidencias/04-linux-servicios/06-vsftpd-prueba-win.png` — Conexión FTP desde `WIN-CLI01` autenticado con `leo.dev`, subida de archivo (`put`) y listado (`ls`).
7. **Pruebas realizadas para comprobar el funcionamiento:**
   *(Pendiente)*
8. **Problemas encontrados y soluciones aplicadas:**
   *(Pendiente)*

---

## Verificación Final de Puertos y Servicios

- [ ] `evidencias/04-linux-servicios/07-puertos-servicios.png` — Salida de `sudo ss -tulpn | grep -E ':(21|22|80|139|445)\b'` y `sudo systemctl status nginx smbd vsftpd sssd --no-pager`.

---

## Notas para Conclusión Individual (20% de la rúbrica)

*(Conforme avancemos, aquí iremos anotando aprendizajes técnicos y problemas reales resueltos para facilitar tu conclusión personal).*
