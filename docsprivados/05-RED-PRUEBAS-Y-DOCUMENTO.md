# 05 — Pruebas de Red, Informe Técnico (PDF APA 7) y Demostración en Vivo

- **Coordinador principal:** Antonio *(con participación técnica y de redacción de los 5 integrantes)*
- **Peso en rúbrica:** Conclusiones grupales (10%) + Conclusiones individuales (20%) + Presentación/Demo (10%) + Cumplimiento documental global de todo el proyecto.
- **Prerrequisito:** Haber leído `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md` y el documento oficial `info.txt`.

---

## 1. Matriz de Pruebas End-to-End (Responsable: Antonio + Equipo)

Antes de tomar el Snapshot final `05-DEMO-FINAL`, **desconectar el Adaptador 2 (NAT)** en las 3 VMs para comprobar que todo funciona **100% offline** sobre `intnet-redes2`, y ejecutar esta matriz de pruebas (guardar capturas en `evidencias/05-pruebas/`):

| # | Prueba | Desde → Hacia | Comando / Acción | Resultado Esperado | Estado |
| :--- | :--- | :--- | :--- | :--- | :---: |
| 1 | Conectividad ICMP | `DC01` ↔ `WIN-CLI01` ↔ `SRV-LINUX01` | `ping 192.168.50.10 / .20 / .30` | 0% pérdida de paquetes | [ ] |
| 2 | DNS Directo | `WIN-CLI01` y `SRV-LINUX01` | `nslookup dc01.redes2.local`, `win-cli01.redes2.local`, `srv-linux01.redes2.local` | Resuelve `.10`, `.20`, `.30` | [ ] |
| 3 | DNS Inverso | `WIN-CLI01` y `SRV-LINUX01` | `nslookup 192.168.50.10` / `.30` | Resuelve FQDNs | [ ] |
| 4 | Login AD en Windows | `WIN-CLI01` | Iniciar sesión con `josh.user@redes2.local` | `whoami` → `redes2\josh.user` | [ ] |
| 5 | Servicio Win 1 (GPO) | `WIN-CLI01` (`josh.user`) | `gpresult /r` + abrir Panel de Control | Bloqueado por `GPO_Restriccion_Admin` | [ ] |
| 6 | Servicio Win 2 (RDP) | `DC01` → `WIN-CLI01` | `mstsc` a `win-cli01.redes2.local` con `antonio.ti` | Sesión remota activa | [ ] |
| 7 | Login AD en Linux + Control de Acceso | `WIN-CLI01` → `SRV-LINUX01` | `ssh rodri.dev@srv-linux01.redes2.local` (OK) y `ssh josh.user@...` (Denegado) | Login autorizado solo a `GRP_TI` / `GRP_Desarrollo` | [ ] |
| 8 | Servicio Linux 1 (Web) | `WIN-CLI01` → `SRV-LINUX01` | Navegador en `http://srv-linux01.redes2.local` | Carga página institucional | [ ] |
| 9 | Servicio Linux 2 (Samba) | `WIN-CLI01` → `SRV-LINUX01` | `\\srv-linux01.redes2.local\compartido` (`leo.dev`) | Crea y lee archivo compartido | [ ] |
| 10 | Servicio Linux 3 (FTP) | `WIN-CLI01` → `SRV-LINUX01` | `ftp srv-linux01.redes2.local` (`leo.dev`) | Login AD + `put` / `ls` exitoso | [ ] |

---

## 2. Checklist de las 10 Evidencias Obligatorias de la Rúbrica

Verificar que el informe PDF y la demo cubran sin falta los 10 puntos de la sección 5 de `info.txt`:

1. [ ] Active Directory instalado y funcionando.
2. [ ] Dominio creado (`redes2.local`) y usuarios registrados.
3. [ ] Unidades organizativas y grupos configurados.
4. [ ] Cliente Windows (`WIN-CLI01`) integrado al dominio.
5. [ ] Inicio de sesión del cliente Windows con un usuario de dominio.
6. [ ] Dos servicios del cliente Windows funcionando (GPO + RDP).
7. [ ] Servidor Linux (`SRV-LINUX01`) integrado al dominio.
8. [ ] Autenticación de usuarios de Active Directory desde Linux.
9. [ ] Tres servicios Linux instalados y funcionando (Nginx + Samba + vsftpd).
10. [ ] Conectividad y comunicación entre los tres sistemas.

---

## 3. Normas Exactas del Informe Técnico Académico (PDF)

Configurar la plantilla en **Google Docs / Word** desde el Día 1 con estos parámetros obligatorios de `info.txt`:

| Elemento | Especificación Obligatoria |
| :--- | :--- |
| **Formato de entrega** | PDF |
| **Tamaño de papel** | Carta |
| **Tipografía** | Arial o Times New Roman *(elegir UNA para todo el documento)* |
| **Texto principal** | 12 puntos |
| **Títulos principales** | 14 puntos, negritas |
| **Subtítulos** | 12 puntos, negritas |
| **Interlineado** | 1.5 |
| **Alineación** | Texto justificado |
| **Márgenes** | 2.5 cm en los cuatro lados |
| **Sangría** | Primera línea de párrafo de 1.27 cm |
| **Numeración** | Todas las páginas numeradas |
| **Tablas y figuras** | Numeradas, tituladas y con fuente (ej. *Figura 1. Diagrama de red. Fuente: Elaboración propia.*) |
| **Referencias** | **Normas APA 7.ª edición** — **OBLIGATORIO citar dentro del texto** (ej. `(Microsoft, 2024)`), NO solo listar URLs al final. |

### 3.1 Estructura Obligatoria del Documento (14 Apartados)
1. **Portada institucional** (UAA, programa académico, asignatura, título, los 5 integrantes, docente y fecha).
2. **Resumen ejecutivo** *(Antonio)*
3. **Índice general** (automático y numerado) *(Antonio)*
4. **Introducción** *(Antonio)*
5. **Objetivos** (General y Específicos) *(Antonio)*
6. **Marco teórico** (AD DS, DNS, Kerberos, Windows Server, Linux, SSSD/realmd, GPO, RDP, Nginx, Samba, FTP — con citas APA 7 en texto) *(Antonio + aportes técnicos de todos)*
7. **Diseño de infraestructura** (Diagrama de arquitectura de red en Draw.io/Lucidchart, tabla de IPs, dominio, OUs/usuarios) *(Antonio)*
8. **Desarrollo e implementación** (Windows Server por **Joao**, Cliente Windows por **Josh**, Integración Linux-AD por **Rodri**)
9. **Configuración de servicios** (2 servicios Windows por **Josh**, 3 servicios Linux por **Leo**)
10. **Pruebas y resultados** (Matriz de pruebas end-to-end y evidencias de interoperabilidad) *(Antonio + Todos)*
11. **Conclusiones grupales (10%)** *(Todos)* — Debe analizar: cumplimiento de objetivos, evaluación de infraestructura, problemas técnicos y soluciones, reflexión sobre interoperabilidad Windows-Linux.
12. **Conclusiones individuales (20%)** *(Cada integrante redacta la suya)* — Ver plantilla abajo.
13. **Referencias bibliográficas (APA 7)** — Usar documentación oficial: Microsoft Learn, Ubuntu Server Documentation, Red Hat Enterprise Linux Documentation, SSSD / realmd / Samba docs. **Incluir y citar dentro del texto** el recurso oficial compartido por el docente:
    - Red Hat. (s. f.). *How to join a Linux system to an Active Directory domain*. Red Hat Blog. https://www.redhat.com/en/blog/linux-active-directory
14. **Anexos** — Scripts de PowerShell, archivos completos (`sssd.conf`, `smb.conf`, `vsftpd.conf`, `netplan`), capturas adicionales.

---

## 4. Plantilla Obligatoria para Cada Procedimiento Técnico

> **REGLA DE `info.txt`:** *"No será suficiente incluir únicamente capturas de pantalla o comandos sin explicar su propósito y resultado."*

Cada vez que Joao, Josh, Rodri o Leo redacten un procedimiento en el documento, deben seguir exactamente estos **8 puntos**:
1. **Nombre y propósito del procedimiento.**
2. **Requisitos previos.**
3. **Pasos realizados en orden cronológico.**
4. **Comandos utilizados y explicación de su propósito.**
5. **Archivos de configuración modificados** (bloque de texto/código explicando qué directiva se cambió y por qué).
6. **Capturas de pantalla** (numeradas como *Figura X*, tituladas y explicadas en el texto).
7. **Pruebas realizadas para comprobar el funcionamiento.**
8. **Problemas encontrados y soluciones aplicadas.**

---

## 5. Plantilla Obligatoria para Conclusiones Individuales (20% de la calificación)

Cada uno de los 5 integrantes (**Joao, Josh, Rodri, Leo y Antonio**) debe escribir una conclusión **original y propia** (no copiar la misma plantilla) que cubra explícitamente estos **5 puntos**:
1. Actividades realizadas y responsabilidades asumidas dentro del equipo.
2. Conocimientos técnicos adquiridos durante la práctica.
3. Problemas técnicos específicos enfrentados y cómo los solucionó.
4. Importancia de la administración integrada de sistemas (Windows + Linux + AD).
5. Aprendizajes y competencias aplicables a un entorno profesional.

---

## 6. Guion para la Demostración en Vivo (10% — Duración sugerida: 10–12 min)

> **Preparación antes de pasar:** Encender las 3 VMs desde el Snapshot `05-DEMO-FINAL` con **Adaptador 2 (NAT) desconectado** para no depender del Wi-Fi del salón. Tener abiertas las ventanas/terminales listas.

1. **Antonio (1.5 min) — Arquitectura y conectividad:**
   - Muestra el diagrama de red (`192.168.50.0/24`, `redes2.local`, `intnet-redes2`).
   - Ejecuta `ping` y `nslookup` demostrando comunicación y DNS entre los 3 nodos.
2. **Joao (2 min) — Active Directory (`DC01`):**
   - Muestra `dsa.msc` (OUs, grupos y usuarios), `dnsmgmt.msc` (zonas directa e inversa) y estado de servicios AD DS / DNS / KDC.
3. **Josh (2.5 min) — Cliente Windows y 2 servicios (`WIN-CLI01`):**
   - Muestra sesión de dominio con `josh.user` (`whoami`), intenta abrir Panel de Control (bloqueado por GPO) y muestra `gpresult /r`.
   - Abre `mstsc` desde `DC01` hacia `win-cli01.redes2.local` con `antonio.ti` demostrando RDP por grupo de AD.
4. **Rodri (2 min) — Linux integrado a AD (`SRV-LINUX01`):**
   - Muestra `realm list` (incluyendo los grupos permitidos), `id rodri.dev`, `kinit` / `klist`.
   - Desde `WIN-CLI01` hace `ssh rodri.dev@srv-linux01.redes2.local` (exitoso) y muestra cómo `josh.user` es rechazado por política de grupo.
5. **Leo (3 min) — 3 Servicios en Linux (`SRV-LINUX01`):**
   - **Nginx:** Abre `http://srv-linux01.redes2.local` en el navegador de `WIN-CLI01`.
   - **Samba:** Abre `\\srv-linux01.redes2.local\compartido` en el Explorador de Windows, crea un archivo y lo muestra en consola Linux (`ls -la`).
   - **FTP (`vsftpd`):** Conecta por `ftp srv-linux01.redes2.local` con `leo.dev`, sube un archivo (`put`) y muestra el archivo en el servidor.
6. **Ronda de preguntas (Todos):** Cada integrante debe conocer el flujo completo (DNS → Kerberos → AD → Servicios) para responder preguntas del docente.
