# Aporte al Marco Teórico y Justificación de Servicios Linux (APA 7)

> **Autor:** Leonardo (Leo) — Módulo 04 (`SRV-LINUX01`: Nginx, Samba y vsftpd)  
> **Uso:** Texto académico formal listo para que Antonio integre en las secciones **6. Marco teórico**, **9. Configuración de servicios (justificación)** y **13. Referencias bibliográficas** del Informe Técnico en PDF.  
> **Nota:** Este borrador refleja la arquitectura oficial en `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` y puede ajustarse si durante las pruebas en `SRV-LINUX01` se aplica alguna modificación.

---

## 1. Servicios de Red en Entornos Heterogéneos (Linux + Active Directory)

En infraestructuras empresariales modernas es habitual combinar servidores basados en Windows Server, encargados de la gestión centralizada de identidades mediante Active Directory Domain Services (AD DS), con servidores Linux especializados en la provisión de servicios de red por su estabilidad, bajo consumo de recursos y flexibilidad de configuración (Canonical, 2024; Red Hat, s. f.). Integrar un servidor Linux al dominio permite que los usuarios autenticados centralmente mediante Kerberos y el servicio SSSD (*System Security Services Daemon*) accedan tanto al sistema operativo como a los servicios de red desplegados, evitando la duplicación de cuentas locales y simplificando la administración de permisos (SSSD, 2024).

En el presente proyecto, el servidor Ubuntu Server (`SRV-LINUX01`, dirección IP `192.168.50.30`) provee tres servicios de red complementarios —servidor web HTTP, servidor de archivos SMB/CIFS y servidor de transferencia de archivos FTP— diseñados para operar sobre la red interna del dominio `redes2.local` y demostrar interoperabilidad real con el cliente Windows (`WIN-CLI01`).

---

## 2. Servicio Web: Nginx (Protocolo HTTP)

Nginx es un servidor web de código abierto de alto rendimiento basado en una arquitectura asíncrona y orientada a eventos (*event-driven*), capaz de atender múltiples conexiones concurrentes con un consumo reducido de memoria en comparación con modelos tradicionales basados en procesos por conexión (F5 NGINX, 2024). Además de servir contenido estático mediante el protocolo HTTP/HTTPS (puertos TCP 80 y 443), se emplea ampliamente como proxy inverso y balanceador de carga en entornos corporativos.

**Justificación en la infraestructura:** La implementación de Nginx en `SRV-LINUX01` permite publicar un portal informativo interno de la organización accesible desde el cliente Windows a través de su nombre de dominio completamente calificado (`http://srv-linux01.redes2.local`). De manera adicional, su operación valida de forma práctica la resolución DNS directa gestionada por el controlador de dominio (`DC01`) y la comunicación TCP/IP entre los nodos Windows y Linux dentro de la red interna `intnet-redes2`.

---

## 3. Servicio de Archivos: Samba (Protocolo SMB/CIFS Integrado con Active Directory)

Samba es una implementación de software libre del conjunto de protocolos SMB/CIFS (*Server Message Block / Common Internet File System*), el cual constituye el estándar nativo de Microsoft Windows para compartir archivos e impresoras en redes locales (Samba Team, 2024a). A través de sus demonios principales (`smbd` para el intercambio de archivos y autenticación, `nmbd` para resolución NetBIOS y `winbindd` para el mapeo de identidades de dominio), Samba permite que un servidor Linux actúe como miembro de un dominio Active Directory (`security = ads`), validando credenciales mediante Kerberos y aplicando controles de acceso basados en grupos de seguridad del dominio (Samba Team, 2024b).

**Justificación en la infraestructura:** En un entorno empresarial heterogéneo, los usuarios en estaciones de trabajo Windows requieren acceder a repositorios centralizados alojados en servidores Linux de manera transparente desde el Explorador de archivos (`\\srv-linux01.redes2.local\compartido`). Configurar Samba integrado con `redes2.local` permite restringir el acceso de lectura y escritura únicamente a los grupos autorizados de Active Directory (`GRP_Desarrollo` y `GRP_TI`), centralizando la gobernanza de permisos en `DC01` sin gestionar contraseñas independientes en el servidor Linux.

---

## 4. Servicio de Transferencia de Archivos: vsftpd (Protocolo FTP Autenticado con AD vía PAM/SSSD)

El Protocolo de Transferencia de Archivos (FTP, *File Transfer Protocol*) permite el intercambio estandarizado de archivos entre clientes y servidores sobre TCP, utilizando tradicionalmente el puerto 21 para el canal de control y el puerto 20 (modo activo) o un rango de puertos dinámicos (modo pasivo, ej. `40000-40100`) para el canal de datos (Canonical, 2024). Para su despliegue en Ubuntu Server se seleccionó `vsftpd` (*Very Secure FTP Daemon*), reconocido por su enfoque en seguridad, estabilidad y soporte de aislamiento de usuarios en su directorio raíz mediante la directiva `chroot` (Evans, s. f.).

Una ventaja fundamental de `vsftpd` en sistemas Linux integrados a Active Directory es su integración con **PAM** (*Pluggable Authentication Modules*). Al delegar la validación de usuarios al módulo `pam_sss`, el servidor FTP autentica directamente a las cuentas del dominio (`leo.dev`, `rodri.dev`) contra `DC01` y garantiza la creación automática de sus directorios personales mediante `pam_mkhomedir`, sin requerir cuentas locales adicionales (SSSD, 2024; Red Hat, s. f.).

**Justificación en la infraestructura:** Provee un mecanismo estandarizado y multiplataforma para la carga (`put`) y descarga (`get`) de archivos desde `WIN-CLI01` hacia `SRV-LINUX01`, demostrando una segunda capa de autenticación centralizada con Active Directory sobre un protocolo de red distinto a SMB y SSH, con políticas de seguridad como deshabilitación de acceso anónimo (`anonymous_enable=NO`) y confinamiento de directorio (`chroot_local_user=YES`).

---

## 5. Referencias Bibliográficas (Formato APA 7.ª Edición)

Canonical. (2024). *Ubuntu Server documentation*. Canonical Ltd. https://ubuntu.com/server/docs

Evans, C. (s. f.). *vsftpd — Probably the most secure and fastest FTP server for UNIX-like systems*. https://security.appspot.com/vsftpd.html

F5 NGINX. (2024). *NGINX documentation*. F5, Inc. https://nginx.org/en/docs/

Red Hat. (s. f.). *How to join a Linux system to an Active Directory domain*. Red Hat Blog. https://www.redhat.com/en/blog/linux-active-directory

Samba Team. (2024a). *What is Samba?*. Samba Wiki. https://www.samba.org/samba/what_is_samba.html

Samba Team. (2024b). *Setting up Samba as a Domain Member*. Samba Wiki. https://wiki.samba.org/index.php/Setting_up_Samba_as_a_Domain_Member

SSSD. (2024). *System Security Services Daemon documentation*. SSSD Project. https://sssd.io/docs/introduction.html
