# 02 — Cliente Windows y Servicios (WIN-CLI01)

- **Responsable:** Josh
- **Peso en rúbrica:** 20%
- **Prerrequisito:** Haber leído `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` y que `DC01` tenga el Snapshot `02-AD-Listo` corriendo.

---

## 1. Objetivo del Módulo

Instalar un cliente **Windows 10/11 Pro o Enterprise** (`WIN-CLI01`), integrarlo al dominio `redes2.local`, comprobar el inicio de sesión con usuarios de Active Directory, e implementar y demostrar **2 servicios/funcionalidades de administración**:
1. **Políticas de Grupo (GPO)** aplicadas al cliente.
2. **Escritorio Remoto (RDP)** habilitado y controlado mediante un grupo de seguridad de Active Directory.

> **ADVERTENCIA:** Windows 10/11 **Home** NO permite unirse a dominios de Active Directory. Usar únicamente edición **Pro** o **Enterprise**.

---

## 2. Datos Exactos de Configuración

- **Hostname:** `WIN-CLI01`
- **Adaptador 1 (`intnet-redes2`):**
  - IP: `192.168.50.20`
  - Máscara: `255.255.255.0`
  - Puerta de enlace: *(vacío)*
  - DNS Preferido: `192.168.50.10` *(ÚNICO DNS — no poner 8.8.8.8)*
- **Zona horaria:** `(UTC-06:00) Guadalajara, Ciudad de México, Monterrey`.

---

## 3. Procedimiento Paso a Paso

### Paso 1: Instalación base, red y verificación de DNS
1. Crear VM en VirtualBox (4 GB RAM, 2 vCPU, 40 GB disco, Adaptador 1: Red Interna `intnet-redes2`).
2. Instalar Windows 10/11 **Pro o Enterprise** con una cuenta local inicial (ej. `localadmin`).
3. Verificar zona horaria y hora sincronizada con `DC01`.
4. Configurar IP estática `192.168.50.20/24` y DNS `192.168.50.10`.
5. Probar conectividad y resolución DNS hacia `DC01`:
   ```powershell
   ping 192.168.50.10
   nslookup redes2.local
   nslookup dc01.redes2.local
   ```
   *(Debe resolver `192.168.50.10`. Si no resuelve, NO continuar hasta corregirlo).*

### Paso 2: Unión al dominio `redes2.local`
1. Abrir **Configuración → Sistema → Acerca de → Cambiar el nombre de este equipo (avanzado)** o ejecutar `sysdm.cpl`.
2. Cambiar el nombre del equipo a `WIN-CLI01` y en *Miembro de* seleccionar **Dominio**: `redes2.local`.
3. Ingresar credenciales de administrador del dominio (`REDES2\Administrator` o `joao.admin@redes2.local`).
4. Esperar el mensaje *"Bienvenido al dominio redes2.local"* y reiniciar.
5. *(Alternativa en PowerShell como Administrador):*
   ```powershell
   Add-Computer -DomainName "redes2.local" -NewName "WIN-CLI01" -Credential (Get-Credential) -Restart
   ```

### Paso 3: Comprobar inicio de sesión con usuario de AD
1. En la pantalla de login de Windows, elegir **Otro usuario**.
2. Iniciar sesión con `josh.user@redes2.local` (o `REDES2\josh.user`) y la contraseña `Redes2026!`.
3. Abrir PowerShell y verificar identidad del dominio:
   ```powershell
   whoami
   whoami /fqdn
   systeminfo | findstr /B /C:"Domain" /C:"Dominio"
   ```
   *(Debe mostrar `redes2\josh.user` y el dominio `redes2.local`).*
4. En `DC01` (con ayuda de Joao), verificar en `dsa.msc` → `Computers` que aparezca el objeto `WIN-CLI01` (y moverlo a `OU=Equipos`).

---

### Paso 4: Servicio/Funcionalidad 1 — Políticas de Grupo (GPO) aplicadas al cliente
**Justificación:** Permite administrar y restringir de forma centralizada la configuración y seguridad de los equipos y usuarios del dominio sin configurar máquina por máquina.

1. En `DC01`, abrir **Group Policy Management** (`gpmc.msc`).
2. Navegar a `redes2.local` → `Empresa` → `Administracion`.
3. Clic derecho sobre `Administracion` → **Create a GPO in this domain, and Link it here...**
   - Nombre: `GPO_Restriccion_Admin`
4. Clic derecho en `GPO_Restriccion_Admin` → **Edit**:
   - Ir a: `User Configuration` → `Policies` → `Administrative Templates` → `Control Panel`
   - Habilitar (**Enabled**): **Prohibit access to Control Panel and PC settings** *(Prohibir el acceso al Panel de control y a Configuración del equipo)*.
5. En `WIN-CLI01` (con sesión iniciada como `josh.user`), forzar la actualización de políticas:
   ```powershell
   gpupdate /force
   gpresult /r
   ```
6. **Prueba de funcionamiento:**
   - Intentar abrir **Panel de Control** o **Configuración** con `josh.user`: Windows debe mostrar el aviso de restricción administrativa.
   - Comprobar en `gpresult /r` que aparece aplicada `GPO_Restriccion_Admin`.
   - *(Contraste opcional para la demo: iniciar sesión con `antonio.ti` — que está en `OU=TI` — y mostrar que a él SÍ le deja abrir Panel de Control).*

---

### Paso 5: Servicio/Funcionalidad 2 — Escritorio Remoto (RDP) controlado por grupo de AD
**Justificación:** Permite a los administradores de soporte técnico (`GRP_TI`) administrar de forma remota las estaciones de trabajo del dominio usando autenticación centralizada de Active Directory.

1. En `WIN-CLI01` (iniciando sesión como administrador del dominio `REDES2\Administrator` o `joao.admin`), habilitar Escritorio Remoto:
   - Ir a **Configuración → Sistema → Escritorio remoto** → Activar **Escritorio remoto**.
   - *(O en `sysdm.cpl` → pestaña Acceso remoto → Permitir conexiones remotas con autenticación a nivel de red NLA).*
2. Hacer clic en **Seleccionar usuarios** → **Agregar...** → buscar y agregar el grupo de Active Directory `GRP_TI` (`REDES2\GRP_TI`).
3. Verificar que el firewall permita RDP (puerto TCP 3389):
   ```powershell
   Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
   ```
4. **Prueba de funcionamiento (desde `DC01` hacia `WIN-CLI01`):**
   - En `DC01`, abrir **Conexión a Escritorio remoto** (`mstsc`).
   - Conectar a `win-cli01.redes2.local` (o `192.168.50.20`).
   - Autenticarse con `antonio.ti@redes2.local` (miembro de `GRP_TI`).
   - Comprobar que abre el escritorio remoto de `WIN-CLI01` y ejecutar `whoami` + `hostname` dentro de la sesión RDP.
   - *(Prueba negativa opcional: intentar conectar con `josh.user`, quien NO está en `GRP_TI`, y mostrar que el acceso es denegado).*

### Paso 6: Snapshot
- **Tomar Snapshot en VirtualBox (`WIN-CLI01`):** `03-WinClient-Unido`.

---

## 4. Recordatorio de Bitácora (para tu parte del reporte)

> **IMPORTANTE:** Mientras haces estos pasos, ve guardando en una nota rápida: (1) los comandos/pasos que sí ejecutaste, (2) **qué errores te salieron y cómo los resolviste**, y (3) tus capturas numeradas. Al terminar, pásale esa nota a tu agente de IA junto con `docsprivados/05-RED-PRUEBAS-Y-DOCUMENTO.md` para que te redacte tu sección con los 8 puntos obligatorios de la rúbrica.

## 5. Checklist de Capturas Obligatorias (guardar en `evidencias/02-win-client/`)

- [ ] `01-red-dns-wincli.png`: `ipconfig /all` y `nslookup redes2.local` desde `WIN-CLI01`.
- [ ] `02-union-dominio.png`: Ventana de *"Bienvenido al dominio redes2.local"*.
- [ ] `03-login-ad-whoami.png`: Sesión iniciada como `josh.user` mostrando `whoami` y `systeminfo`.
- [ ] `04-gpo-configuracion.png`: GPO `GPO_Restriccion_Admin` configurada y vinculada a `OU=Administracion`.
- [ ] `05-gpo-prueba.png`: Salida de `gpupdate /force`, `gpresult /r` y el mensaje de bloqueo al intentar abrir Panel de Control / Configuración.
- [ ] `06-rdp-configuracion.png`: Escritorio Remoto habilitado en `WIN-CLI01` con el grupo `REDES2\GRP_TI` autorizado.
- [ ] `07-rdp-prueba.png`: Sesión RDP activa desde `DC01` hacia `win-cli01.redes2.local` iniciada con `antonio.ti` y salida de `whoami`.

---

## 5. Problemas Comunes y Soluciones

- **Error "No se pudo contactar a un controlador de dominio":** Casi siempre es porque el DNS no apunta exclusivamente a `192.168.50.10` o porque el Adaptador 1 no está en `intnet-redes2`.
- **La GPO no se aplica inmediatamente:** Ejecutar `gpupdate /force`, cerrar sesión y volver a iniciar sesión con `josh.user`. Verificar que `josh.user` esté dentro de `OU=Administracion`.
- **Error de credenciales o red en RDP:** Verificar que el firewall de `WIN-CLI01` tenga habilitada la regla de Remote Desktop (puerto 3389) en el perfil de Dominio y que `antonio.ti` pertenezca a `GRP_TI`.
