# 00 — Arquitectura y Estándares del Proyecto (Fuente Única de Verdad)

> **REGLA:** Todos los integrantes del equipo y todos los agentes de IA deben respetar exactamente los nombres, IPs, credenciales de laboratorio, estructura de AD y servicios definidos en este documento. Si el equipo decide cambiar algún dato, debe actualizarse primero aquí.

---

## 1. Hipervisor y Configuración de Red en VirtualBox

- **Hipervisor:** Oracle VM VirtualBox.
- **Estrategia de doble adaptador de red** (para que el dominio funcione **100% offline** el día de la presentación y no dependa del Wi-Fi de la universidad):
  - **Adaptador 1 (Red del Dominio — OBLIGATORIO):**
    - Conectado a: **Red interna** (*Internal Network*)
    - Nombre exacto de la red: `intnet-redes2`
    - Modo promiscuo: *Denegar* (o *Permitir VMs* si hiciera falta diagnóstico).
  - **Adaptador 2 (Salida a Internet — Solo para instalar paquetes/updates):**
    - Conectado a: **NAT**
    - **IMPORTANTE:** Una vez instalados todos los paquetes y servicios, el Adaptador 2 puede deshabilitarse (o desconectarse el cable virtual) durante las pruebas finales y la exposición para comprobar que el dominio opera sin depender de internet ni de DNS externos.
    - **CUIDADO CON EL DNS:** En el Adaptador 2 (NAT), asegúrate de que el sistema operativo NO use el DNS de NAT como prioritario para resolver el dominio `redes2.local`. El DNS primario del dominio SIEMPRE es `192.168.50.10`.

---

## 2. Tabla de Máquinas Virtuales y Direccionamiento IP

- **Red del dominio:** `192.168.50.0/24`
- **Máscara de subred:** `255.255.255.0`
- **Dominio Active Directory (FQDN):** `redes2.local`
- **Nombre NetBIOS del dominio:** `REDES2`
- **DNS Primario (todas las VMs):** `192.168.50.10`
- **Zona horaria (todas las VMs):** `America/Mexico_City` (UTC-6). **CRÍTICO:** Kerberos falla si la diferencia de hora entre máquinas supera los 5 minutos.

| Máquina Virtual | Sistema Operativo | Hostname | FQDN | IP Estática (`intnet-redes2`) | Gateway (`intnet-redes2`) | DNS Primario | RAM Sugerida | Disco | Responsable |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Controlador de Dominio** | Windows Server 2022 (Desktop Experience) | `DC01` | `dc01.redes2.local` | `192.168.50.10` | *(vacío en red interna)* | `127.0.0.1` (y `192.168.50.10`) | 4 GB (mín. 2 GB) | 40 GB | Joao |
| **Cliente Windows** | Windows 10/11 **Pro o Enterprise** *(NO Home)* | `WIN-CLI01` | `win-cli01.redes2.local` | `192.168.50.20` | *(vacío en red interna)* | `192.168.50.10` | 4 GB (mín. 2 GB) | 40 GB | Josh |
| **Servidor Linux** | Ubuntu Server 22.04 LTS o 24.04 LTS | `SRV-LINUX01` | `srv-linux01.redes2.local` | `192.168.50.30` | *(vacío en red interna)* | `192.168.50.10` | 2 GB (mín. 1 GB) | 25 GB | Rodri + Leo |

*(Nota sobre Gateway: como `intnet-redes2` es una red interna sin router, dejar la puerta de enlace vacía en el Adaptador 1 evita conflictos de ruteo con el Adaptador 2 NAT cuando se descargan paquetes.)*

---

## 3. Estructura de Active Directory (OUs, Grupos y Usuarios)

Joao debe crear exactamente esta estructura en `DC01` para que Josh, Rodri y Leo puedan probar GPOs, RDP, login en Linux, Samba y FTP sin confusiones:

### 3.1 Unidades Organizativas (OUs)
Bajo `redes2.local`:
- `OU=Empresa`
  - `OU=TI` (Administradores y soporte técnico)
  - `OU=Desarrollo` (Desarrolladores / acceso a servicios Linux)
  - `OU=Administracion` (Usuarios estándar con GPO restrictiva aplicada)
  - `OU=Equipos` (Aquí se registran/mueven `WIN-CLI01` y `SRV-LINUX01` para orden y GPOs limpias)

### 3.2 Grupos de Seguridad (Ámbito: Global / Tipo: Seguridad)
- `GRP_TI` (en `OU=TI`) — Permisos administrativos, acceso RDP y acceso SSH/Samba/FTP.
- `GRP_Desarrollo` (en `OU=Desarrollo`) — Acceso a servicios Linux (SSH, Samba, FTP).
- `GRP_Administracion` (en `OU=Administracion`) — Usuarios estándar sujetos a GPO restrictiva (y sin acceso SSH a Linux vía `realm permit`).
- `GRP_LinuxAdmins` (en `OU=TI`) — Grupo autorizado para `sudo` en `SRV-LINUX01`.

### 3.3 Usuarios de Laboratorio
*(Usar una contraseña estándar que cumpla complejidad de AD, ej. `Redes2026!` — cambiar si el equipo prefiere otra, pero anotarla aquí y usar la misma para pruebas).*

| Nombre completo | Usuario (`sAMAccountName`) | UPN | OU | Grupos | Uso principal en pruebas |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Joao Admin | `joao.admin` | `joao.admin@redes2.local` | `OU=TI` | `GRP_TI`, `GRP_LinuxAdmins` | Pruebas de administración y SSH/sudo en Linux |
| Joshua Cliente | `josh.user` | `josh.user@redes2.local` | `OU=Administracion` | `GRP_Administracion` | Login en `WIN-CLI01`, prueba de GPO restrictiva y prueba negativa en Linux/RDP |
| Rodrigo Linux | `rodri.dev` | `rodri.dev@redes2.local` | `OU=Desarrollo` | `GRP_Desarrollo` | Prueba de login AD en `SRV-LINUX01` (consola y SSH) |
| Leonardo Servicios | `leo.dev` | `leo.dev@redes2.local` | `OU=Desarrollo` | `GRP_Desarrollo` | Pruebas de Samba y FTP autenticados con AD desde `WIN-CLI01` |
| Antonio Redes | `antonio.ti` | `antonio.ti@redes2.local` | `OU=TI` | `GRP_TI` | Prueba de Escritorio Remoto (RDP) hacia `WIN-CLI01` |

---

## 4. Servicios Oficiales Seleccionados (5 Servicios + Validación AD)

### Cliente Windows (`WIN-CLI01`) — 2 Servicios / Funcionalidades
1. **Políticas de Grupo (GPO) aplicadas al cliente:**
   - GPO `GPO_Restriccion_Admin` vinculada a `OU=Administracion` que **bloquea el acceso al Panel de Control / Configuración**. Se comprueba iniciando sesión en `WIN-CLI01` con `josh.user` y ejecutando `gpresult /r`.
2. **Escritorio Remoto (RDP) centralizado con control por grupo de AD:**
   - Habilitado en `WIN-CLI01`, restringido para permitir acceso a miembros de `GRP_TI`, y probado conectándose desde `DC01` hacia `win-cli01.redes2.local` (`192.168.50.20`) con `antonio.ti@redes2.local`.

### Servidor Linux (`SRV-LINUX01`) — 3 Servicios de Red
*(Nota: **SSH** también estará activo para demostrar el login de usuarios de AD y el control de acceso con `realm permit`, pero **NO** se cuenta como uno de los 3 servicios principales para evitar que el docente lo descarte por venir preinstalado).*

1. **Servidor Web (`Nginx`):**
   - Sirve una página HTML institucional del proyecto (mostrando nombre del equipo, integrantes y estado del dominio).
   - Accesible desde el navegador de `WIN-CLI01` por nombre DNS: `http://srv-linux01.redes2.local` (y `http://192.168.50.30`).
2. **Servidor de Archivos (`Samba`) integrado con Active Directory:**
   - Carpeta compartida `/srv/samba/compartido` accesible desde el Explorador de Windows en `WIN-CLI01` (`\\srv-linux01.redes2.local\compartido`) autenticándose con usuarios de AD (`leo.dev` / `GRP_Desarrollo`).
3. **Servidor FTP (`vsftpd`) autenticado con usuarios de AD (vía PAM/SSSD):**
   - Permite a usuarios del dominio (`leo.dev` o `rodri.dev`) conectarse desde `WIN-CLI01` por FTP (`ftp srv-linux01.redes2.local`), subir y descargar archivos en su directorio asignado usando su cuenta de Active Directory.

---

## 5. Política Obligatoria de Snapshots en VirtualBox

Tomar snapshots en las 3 VMs en estos puntos exactos (nunca borrar el anterior hasta validar el siguiente):

1. `01-OS-Base` — Sistema operativo instalado, hostname, zona horaria e IPs configuradas.
2. `02-AD-Listo` — `DC01` promovido con AD DS, DNS, OUs, grupos y usuarios creados.
3. `03-WinClient-Unido` — `WIN-CLI01` unido al dominio + GPO y RDP funcionando.
4. `04-Linux-Unido-AD` — `SRV-LINUX01` unido al dominio con `realmd`/`sssd`, `realm permit` y login AD comprobado.
5. `05-DEMO-FINAL` — Los 3 servicios de Linux listos, pruebas end-to-end aprobadas y **Adaptador 2 (NAT) desconectado** (probado 100% offline).

---

## 6. Convención para Capturas de Pantalla (Evidencias)

- Guardar todas las capturas en el repo en `evidencias/<carpeta>/` con nombres descriptivos numerados:
  - `evidencias/01-ad/01-ip-estatica.png`, `02-promocion-dc.png`, etc.
  - `evidencias/02-win-client/`
  - `evidencias/03-linux-ad/`
  - `evidencias/04-linux-servicios/`
  - `evidencias/05-pruebas/`
- Siempre que se capture una terminal o ventana importante, procurar que sea legible (buen tamaño de fuente) y que se vea el hostname / usuario / resultado del comando.
