# Bitácora Técnica — Módulo 05: Arquitectura de Red, Pruebas End-to-End y Documentación (PDF APA 7)

- **Integrante responsable:** Carlos Antonio (Antonio)
- **Usuario de laboratorio:** `antonio.ti` (`antonio.ti@redes2.local` — `OU=TI`, grupo `GRP_TI`)
- **Rol:** Coordinador de Arquitectura de Red, Pruebas End-to-End, Informe Técnico Académico (APA 7) y Demostración en Vivo
- **Prerrequisito de pruebas:** Snapshot `04-Linux-Unido-AD` y servicios Linux completados sobre `intnet-redes2`

> Esta bitácora sigue los lineamientos de `docsprivados/05-RED-PRUEBAS-Y-DOCUMENTO.md` y la rúbrica de `info.txt`.

---

## Estado General del Módulo

### Fase A — Preparación Documental y Diseño (En progreso / Completado base)
- [x] **Bitácora inicializada:** `bitacoras/05-antonio-pruebas.md` creada con matriz de pruebas y checklist de rúbrica.
- [x] **Borrador Fase A (Apartados 1–7 + Referencias APA 7):** Redactado en `bitacoras/05-antonio-informe-fase-a-apa7.md` (incluye integración del aporte teórico de Leo).
- [x] **Diagrama de arquitectura de red:** Archivo editable generado en `evidencias/05-pruebas/diagrama-red-redes2.drawio` (listo para exportar a PNG e insertar como *Figura 1*).
- [ ] **Plantilla en Google Docs / Word:** Pasar el borrador de Fase A a Google Docs/Word aplicando márgenes `2.5 cm`, Arial/Times `12 pt`, interlineado `1.5`, sangría `1.27 cm` y numeración de páginas.

### Fase B — Pruebas End-to-End Offline (Pendiente de VMs)
- [ ] Desconectar **Adaptador 2 (NAT)** en `DC01`, `WIN-CLI01` y `SRV-LINUX01`.
- [ ] Ejecutar y capturar las 10 pruebas de la matriz en `evidencias/05-pruebas/`.
- [ ] Validar Snapshot final `05-DEMO-FINAL` en las 3 VMs.

### Fase C — Cierre del Informe PDF y Demo en Vivo
- [ ] Integrar bitácoras de Joao (`01`), Josh (`02`), Rodri (`03`) y Leo (`04`) en Apartados 8, 9 y 10 (verificando los 8 puntos por procedimiento).
- [ ] Verificar las 10 evidencias obligatorias de la rúbrica.
- [ ] Redactar Conclusiones Grupales (10%) y recopilar las 5 Conclusiones Individuales (20%).
- [ ] Exportar PDF final y ensayar guion de exposición (10–12 min).

---

## 1. Matriz de Pruebas End-to-End (100% Offline sobre `intnet-redes2`)

> **Importante:** Antes de ejecutar estas pruebas, confirmar que el **Adaptador 2 (NAT)** está desconectado en las 3 VMs.

| # | Prueba | Desde → Hacia | Comando / Acción | Resultado Esperado | Captura (`evidencias/05-pruebas/`) | Estado |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| 1 | Conectividad ICMP | `DC01` ↔ `WIN-CLI01` ↔ `SRV-LINUX01` | `ping 192.168.50.10 / .20 / .30` | 0% pérdida de paquetes | `01-icmp-conectividad.png` | [ ] |
| 2 | DNS Directo | `WIN-CLI01` y `SRV-LINUX01` | `nslookup dc01.redes2.local`, `win-cli01.redes2.local`, `srv-linux01.redes2.local` | Resuelve `.10`, `.20`, `.30` | `02-dns-directo.png` | [ ] |
| 3 | DNS Inverso | `WIN-CLI01` y `SRV-LINUX01` | `nslookup 192.168.50.10` / `.30` | Resuelve FQDNs | `03-dns-inverso.png` | [ ] |
| 4 | Login AD en Windows | `WIN-CLI01` | Iniciar sesión con `josh.user@redes2.local` | `whoami` → `redes2\josh.user` | `04-win-login-ad.png` | [ ] |
| 5 | Servicio Win 1 (GPO) | `WIN-CLI01` (`josh.user`) | `gpresult /r` + abrir Panel de Control | Bloqueado por `GPO_Restriccion_Admin` | `05-win-gpo-restriccion.png` | [ ] |
| 6 | Servicio Win 2 (RDP) | `DC01` → `WIN-CLI01` | `mstsc` a `win-cli01.redes2.local` con `antonio.ti` | Sesión remota activa | `06-win-rdp-antonio.png` | [ ] |
| 7 | Login AD en Linux + Control de Acceso | `WIN-CLI01` → `SRV-LINUX01` | `ssh rodri.dev@srv-linux01.redes2.local` (OK) y `ssh josh.user@...` (Denegado) | Login autorizado solo a `GRP_TI` / `GRP_Desarrollo` | `07-linux-ssh-realm-permit.png` | [ ] |
| 8 | Servicio Linux 1 (Web) | `WIN-CLI01` → `SRV-LINUX01` | Navegador en `http://srv-linux01.redes2.local` | Carga página institucional | `08-linux-nginx-web.png` | [ ] |
| 9 | Servicio Linux 2 (Samba) | `WIN-CLI01` → `SRV-LINUX01` | `\\srv-linux01.redes2.local\compartido` (`leo.dev`) | Crea y lee archivo compartido | `09-linux-samba-compartido.png` | [ ] |
| 10 | Servicio Linux 3 (FTP) | `WIN-CLI01` → `SRV-LINUX01` | `ftp srv-linux01.redes2.local` (`leo.dev`) | Login AD + `put` / `ls` exitoso | `10-linux-vsftpd-ftp.png` | [ ] |

---

## 2. Checklist de las 10 Evidencias Obligatorias (`info.txt` Sección 5)

1. [ ] Active Directory instalado y funcionando (`DC01`).
2. [ ] Dominio creado (`redes2.local`) y usuarios registrados.
3. [ ] Unidades organizativas y grupos configurados (`OU=Empresa`, `TI`, `Desarrollo`, `Administracion`, `Equipos`).
4. [ ] Cliente Windows (`WIN-CLI01`) integrado al dominio.
5. [ ] Inicio de sesión del cliente Windows con un usuario de dominio (`josh.user`).
6. [ ] Dos servicios del cliente Windows funcionando (`GPO_Restriccion_Admin` + `RDP`).
7. [ ] Servidor Linux (`SRV-LINUX01`) integrado al dominio (`realmd` + `sssd` + Kerberos).
8. [ ] Autenticación de usuarios de Active Directory desde Linux (`realm permit`).
9. [ ] Tres servicios Linux instalados y funcionando (`Nginx` + `Samba` + `vsftpd`).
10. [ ] Conectividad y comunicación entre los tres sistemas (100% offline sobre `intnet-redes2`).

---

## 3. Notas para Conclusión Individual de Antonio (20% de la rúbrica)

Recordar cubrir estos 5 puntos de forma original al cierre del proyecto:
1. Actividades realizadas y responsabilidades asumidas (diseño de arquitectura, coordinación documental APA 7, matriz de pruebas offline y validación RDP con `antonio.ti`).
2. Conocimientos técnicos adquiridos.
3. Problemas técnicos específicos enfrentados y cómo se solucionaron.
4. Importancia de la administración integrada de sistemas (Windows + Linux + AD).
5. Aprendizajes y competencias aplicables a un entorno profesional.
