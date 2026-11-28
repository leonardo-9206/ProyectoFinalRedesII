# Parte de Joao — Windows Server 2025 & Active Directory (`DC01`)

Esta carpeta contiene una copia organizada de todo lo realizado para el módulo **01 — Windows Server & Active Directory (`DC01`)** de **Joao**.

## Resumen de Configuración en `DC01`

- **VM en VirtualBox:** `DC01` (Windows Server 2025 Standard Evaluation — Desktop Experience, 4 GB RAM, 2 vCPU)
- **Hostname / FQDN:** `DC01` / `dc01.redes2.local`
- **Dominio Active Directory:** `redes2.local` (NetBIOS: `REDES2`)
- **IP Estática (`Ethernet 2` / `intnet-redes2`):** `192.168.50.10/24` (DNS: `192.168.50.10`, `127.0.0.1`)
- **Zona horaria:** `Central Standard Time (Mexico)` (`UTC-06:00`)
- **Credencial de Administrador del Dominio:** `REDES2\Administrator` / `Redes2026!`
- **Zonas DNS activas:**
  - Directa: `redes2.local` (integrada en AD, `dc01` → `192.168.50.10`)
  - Inversa: `50.168.192.in-addr.arpa` (`PTR` `10` → `dc01.redes2.local`)
- **Firewall:** Regla `File and Printer Sharing (Echo Request - ICMPv4-In)` habilitada
- **Snapshots en VirtualBox:** `01-OS-Base` y `02-AD-Listo`

## Estructura de Active Directory Creada (`OU=Empresa,DC=redes2,DC=local`)

- **OUs:** `Empresa`, `TI`, `Desarrollo`, `Administracion`, `Equipos`
- **Grupos de Seguridad (Global):** `GRP_TI`, `GRP_LinuxAdmins`, `GRP_Desarrollo`, `GRP_Administracion`
- **Usuarios (contraseña `Redes2026!`):**
  - `joao.admin` (`OU=TI`) → `GRP_TI`, `GRP_LinuxAdmins`
  - `josh.user` (`OU=Administracion`) → `GRP_Administracion`
  - `rodri.dev` (`OU=Desarrollo`) → `GRP_Desarrollo`
  - `leo.dev` (`OU=Desarrollo`) → `GRP_Desarrollo`
  - `antonio.ti` (`OU=TI`) → `GRP_TI`

## Archivos en esta carpeta

- `bitacora-joao-ad.md` — Copia de [bitacoras/01-joao-ad.md](../bitacoras/01-joao-ad.md) con los 8 puntos de la rúbrica.
- `01-setup-ad-structure.ps1` — Copia de [scripts/01-setup-ad-structure.ps1](../scripts/01-setup-ad-structure.ps1).
- `evidencias/` — Copias de las 6 capturas guardadas en [evidencias/01-ad/](../evidencias/01-ad/).
