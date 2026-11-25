# Bitácora Técnica de Implementación — Windows Server & Active Directory (DC01)

- **Responsable:** Joao
- **Rol:** Administrador de Active Directory & Servicios de Dominio
- **Servidor:** `DC01` (`dc01.redes2.local`)
- **IP Estática:** `192.168.50.10/24` (Red Interna `intnet-redes2`)
- **Dominio:** `redes2.local` (NetBIOS: `REDES2`)

---

## Registro de Procedimientos Técnicos (8 Puntos Rúbrica)

> Este documento se actualiza automáticamente durante cada fase de instalación y configuración para servir como base directa del Informe Técnico Académico en PDF (APA 7).

### Estado General del Módulo:
- [ ] Creación de VM `DC01` en VirtualBox con Red Interna `intnet-redes2`.
- [ ] Instalación de Windows Server 2022 (Desktop Experience).
- [ ] Configuración de IP estática (`192.168.50.10`) y Hostname (`DC01`).
- [ ] Snapshot `01-OS-Base`.
- [ ] Instalación de rol AD DS y DNS Server.
- [ ] Promoción a Controlador de Dominio (Nuevo bosque `redes2.local`).
- [ ] Configuración y verificación de Zonas DNS (Directa e Inversa).
- [ ] Habilitación de regla ICMPv4 en Firewall de Windows.
- [ ] Creación de Unidades Organizativas (OUs), Grupos de Seguridad y Usuarios con PowerShell.
- [ ] Verificación de autenticación y servicios de AD.
- [ ] Snapshot `02-AD-Listo`.

---

*(Los registros detallados de cada procedimiento con sus 8 puntos obligatorios se irán agregando conforme se ejecuten los pasos).*
