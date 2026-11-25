# Proyecto Final — Administración e Integración de Servicios de Red

> **Nota para los integrantes y agentes de IA (Antigravity / Claude / Gemini):**
> La carpeta `docsprivados/` contiene la **fuente única de verdad** del proyecto final de Redes 2 / Administración de Sistemas.
> - **Si eres humano y quieres entender rápido todo sin tanto tecnicismo:** empieza por [`docsprivados/GUIA-MODO-COMPA.md`](docsprivados/GUIA-MODO-COMPA.md).
> - **Si eres un agente de IA o vas a ejecutar comandos:** lee primero [`docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md`](docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md) y luego la guía técnica de tu rol. No inventes nombres de dominio, IPs ni usuarios distintos a los definidos ahí.

---

## 1. Resumen del Proyecto

Implementar una infraestructura de red empresarial interoperable en **VirtualBox** con **3 máquinas virtuales** integradas bajo un mismo dominio de **Active Directory**:

1. **Windows Server (`DC01`)** — Controlador de Dominio con **AD DS + DNS**, OUs, grupos y usuarios. *(10% de la rúbrica)*
2. **Cliente Windows 10/11 Pro o Enterprise (`WIN-CLI01`)** — Unido al dominio + **2 servicios/funcionalidades** de administración. *(20% de la rúbrica)*
3. **Servidor Linux Ubuntu Server (`SRV-LINUX01`)** — Unido al dominio de AD (`realmd` + `sssd` + Kerberos + `realm permit`) + **3 servicios de red** funcionales. *(30% de la rúbrica)*

Además, se entrega un **Informe Técnico Académico en PDF (formato APA 7 estricto)** con conclusiones grupales *(10%)* e individuales *(20%)*, y una **Demostración práctica en vivo obligatoria** *(10%)*.

---

## 2. Mapa de Documentos y Roles del Equipo (en `docsprivados/`)

| Archivo | Responsable(s) | Contenido |
| :--- | :--- | :--- |
| [GUIA-MODO-COMPA.md](docsprivados/GUIA-MODO-COMPA.md) | **Todos** | Explicación sencilla, diccionario de términos y paso a paso en español normal para no perderse. |
| [INSTRUCCIONES-PARA-AGENTES-IA.md](docsprivados/INSTRUCCIONES-PARA-AGENTES-IA.md) | **Agentes de IA** | Protocolo de Modo Copiloto paso a paso, avisos de capturas y **Auto-Bitácora** en `bitacoras/`. |
| [00-ARQUITECTURA-Y-ESTANDARES.md](docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md) | **Todos / IAs** | Esquema de red VirtualBox, IPs, dominio, OUs, usuarios, servicios oficiales y regla de Snapshots. **Lectura obligatoria.** |
| [01-WINDOWS-SERVER-AD.md](docsprivados/01-WINDOWS-SERVER-AD.md) | **Joao** | Instalación de Windows Server, IP estática, AD DS, DNS, OUs, grupos, usuarios y verificación. |
| [02-WINDOWS-CLIENTE.md](docsprivados/02-WINDOWS-CLIENTE.md) | **Josh** | Instalación de Windows Pro/Enterprise, unión al dominio, login AD y 2 servicios (GPO + RDP). |
| [03-LINUX-INTEGRACION-AD.md](docsprivados/03-LINUX-INTEGRACION-AD.md) | **Rodri** | Instalación de Ubuntu Server, Netplan/DNS, NTP y unión al dominio con `realmd` + `sssd` + Kerberos + `realm permit` (basado en guía oficial de Red Hat). |
| [04-LINUX-SERVICIOS.md](docsprivados/04-LINUX-SERVICIOS.md) | **Leo** | Instalación, configuración y pruebas de los 3 servicios en Linux (Nginx, Samba integrado con AD y vsftpd autenticado con AD). |
| [05-RED-PRUEBAS-Y-DOCUMENTO.md](docsprivados/05-RED-PRUEBAS-Y-DOCUMENTO.md) | **Antonio (+ Todos)** | Pruebas end-to-end offline, checklist de las 10 evidencias obligatorias, formato exacto del PDF APA 7, conclusiones y guion de la demo. |

---

## 3. Cómo Trabajar los 5 en Equipo sin Hacernos Cuello de Botella

1. **Una sola "Laptop Maestra":** Elegir la laptop con más RAM (mínimo 16 GB, ideal 32 GB) y espacio en SSD. Ahí vivirán las **3 VMs definitivas** de VirtualBox que se llevarán el día de la exposición.
2. **GitHub para configs, scripts y capturas:** Subir configs (`sssd.conf`, `smb.conf`, `vsftpd.conf`, scripts PowerShell) y capturas en `evidencias/`.
3. **Trabajo en paralelo + Integración remota/presencial:** Usar **AnyDesk / RustDesk / Tailscale** o sesiones en Discord sobre la Laptop Maestra cuando toque integrar.
4. **Google Docs / Word en OneDrive desde el Día 1:** Cada quien redacta su sección y pega sus capturas explicadas conforme avanza.
5. **Regla de Oro — Snapshots en VirtualBox:** Tomar un **Snapshot** antes y después de cada hito importante.

---

## 4. Instrucciones Rápidas para Agentes de IA

Si eres un agente de IA (Claude, Antigravity, Gemini, etc.) ayudando a un integrante del equipo:
1. Lee siempre `docsprivados/INSTRUCCIONES-PARA-AGENTES-IA.md` y `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` antes de empezar.
2. Lee la guía específica del integrante en `docsprivados/`.
3. Trabaja en **Modo Copiloto paso a paso**, avisa explícitamente cuándo tomar cada captura (`📸 CAPTURA OBLIGATORIA`) y ve llenando automáticamente la bitácora del integrante en `bitacoras/0X-<nombre>.md` con los 8 puntos que exige la rúbrica.
4. Nunca sugieras cambiar la red del dominio a Modo Puente (*Bridged*): el dominio opera en **Red Interna (`intnet-redes2`)** para garantizar que funcione offline el día de la exposición.
