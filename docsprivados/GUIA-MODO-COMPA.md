# Guía Modo Compa — ¿Qué diablos tenemos que hacer en este proyecto?

> **Lee esto primero si entre tanto tecnicismo ya te mareaste.**
> Aquí está explicado en español normal qué es el proyecto, qué significa cada palabra rara y exactamente qué le toca hacer a cada uno de los 5. Los comandos exactos y las configs técnicas están en los otros `.md` de `docsprivados/` (esos se los pasan a su IA o los siguen paso a paso).

---

## 1. ¿De qué trata el proyecto en una analogía fácil?

Imagínense que montamos la red de una **empresa chiquita** usando **3 máquinas virtuales en VirtualBox**:

1. **Windows Server (`DC01` — la compu de Joao):** Es el **jefe de seguridad / recepcionista** de la empresa. Tiene la lista oficial de quién trabaja aquí (usuarios y contraseñas), en qué departamento está cada quien (OUs y grupos) y el directorio telefónico de la oficina (DNS, para saber qué IP tiene cada compu).
2. **Cliente Windows (`WIN-CLI01` — la compu de Josh):** Es la **compu de escritorio de un empleado**. En vez de entrar con una cuenta normal de Windows, entras con tu usuario de la empresa (`josh.user@redes2.local`). Además, el jefe le pone reglas automáticas (ej. bloquearle el Panel de Control) y los de TI se pueden meter a controlarla a distancia (Escritorio Remoto).
3. **Servidor Linux (`SRV-LINUX01` — la compu de Rodri y Leo):** Es el **cuarto de servidores de la empresa**. Aunque es Linux, lo conectamos al "jefe" de Windows para que reconozca a los mismos empleados (si `rodri.dev` o `leo.dev` meten su contraseña de Windows en Linux, los deja pasar). Y aparte ofrece **3 servicios** que se usan desde la compu Windows:
   - Una **página web interna** (Nginx).
   - Una **carpeta compartida en red** (Samba).
   - Un **servidor de transferencia de archivos** (FTP / vsftpd).

**El chiste del proyecto:** Que el día de la exposición el profe vea las 3 máquinas prendidas, hablando entre sí **sin internet**, y que con una misma cuenta creada en Windows Server puedas iniciar sesión en Windows, iniciar sesión en Linux y usar los servicios de red.

---

## 2. Diccionario rápido (para no perderse con las siglas)

- **Active Directory (AD DS):** El "registro civil" de la empresa. Guarda usuarios, contraseñas, grupos y equipos.
- **Dominio (`redes2.local`):** El nombre de nuestra red empresarial.
- **DNS:** La agenda que traduce nombres fáciles (`srv-linux01.redes2.local`) a números IP (`192.168.50.30`). **Si el DNS falla, nada funciona.**
- **OU (Unidad Organizativa):** Carpetas dentro de Active Directory para ordenar gente (nosotros hicimos `TI`, `Desarrollo`, `Administracion` y `Equipos`).
- **GPO (Política de Grupo):** Reglas que el Windows Server le impone a la fuerza al Cliente Windows (ej. "los de Administración no pueden abrir el Panel de Control").
- **RDP (Escritorio Remoto):** Meterte a ver y controlar la pantalla de otra compu Windows desde la red.
- **Kerberos / SSSD / `realmd`:** Los "traductores" que le permiten a Linux preguntarle al Windows Server: *"oye, ¿este usuario y contraseña sí son tuyos?"*.
- **Snapshot (Instantánea):** Un "punto de guardado" en VirtualBox (como en un videojuego). Si algo se rompe, regresas al guardado en 5 segundos.
- **Red Interna (`intnet-redes2`):** Un cable virtual privado entre nuestras 3 VMs. Así no dependemos del Wi-Fi de la UAA el día de la exposición.

---

## 3. ¿Cómo nos vamos a organizar los 5? (Paso a paso)

### Antes de empezar (Todos — 20 min)
1. Elegimos **UNA sola laptop potente** (la "Laptop Maestra" con mínimo 16 GB de RAM) donde van a vivir las 3 VMs finales para la exposición.
2. Creamos un **Google Docs compartido** (ya con el formato del profe: Arial/Times 12, interlineado 1.5, márgenes 2.5 cm, APA 7) y un **repo de GitHub** para subir capturas y archivos de config.
3. Nadie inventa IPs ni nombres nuevos: todos usamos la tabla de `00-ARQUITECTURA-Y-ESTANDARES.md`.

---

### Turno 1: Joao — El Jefe (`DC01` — Windows Server)
- **Tu guía técnica:** `01-WINDOWS-SERVER-AD.md`
- **Qué haces en español simple:**
  1. Instalas Windows Server en VirtualBox en la red interna `intnet-redes2` con IP `192.168.50.10`.
  2. Instalas Active Directory (AD DS) y DNS, y creas el dominio `redes2.local`.
  3. Corres el script de PowerShell (ya viene listo en tu `.md`) para crear las carpetas (OUs), los grupos (`GRP_TI`, `GRP_Desarrollo`, `GRP_Administracion`, `GRP_LinuxAdmins`) y nuestros 5 usuarios (`joao.admin`, `josh.user`, `rodri.dev`, `leo.dev`, `antonio.ti`).
  4. Sacas capturas de todo y guardas el **Snapshot `02-AD-Listo`**.
- **Cuando termines:** Ya le diste luz verde a Josh y a Rodri para conectarse.

---

### Turno 2: Josh — La Compu de Oficina (`WIN-CLI01` — Cliente Windows)
- **Tu guía técnica:** `02-WINDOWS-CLIENTE.md`
- **Qué haces en español simple:**
  1. Instalas Windows 10 u 11 **Pro o Enterprise** (¡OJO! Home NO sirve porque Microsoft le bloqueó lo de dominios).
  2. Le pones IP `192.168.50.20` y le dices que su **único DNS** es `192.168.50.10` (la compu de Joao).
  3. Unes la compu al dominio `redes2.local` y pruebas iniciar sesión con `josh.user@redes2.local`.
  4. Configuras los **2 servicios de Windows**:
     - **Servicio 1 (GPO):** Desde el server de Joao creas la regla que le bloquea el Panel de Control a `OU=Administracion`, y en tu compu pruebas con `josh.user` que efectivamente ya no lo deja abrirlo.
     - **Servicio 2 (RDP):** Prendes Escritorio Remoto en tu compu, le das permiso al grupo `GRP_TI`, y pruebas conectarte desde `DC01` usando la cuenta de `antonio.ti`.
  5. Sacas capturas y guardas el **Snapshot `03-WinClient-Unido`**.

---

### Turno 3: Rodri — Conectar Linux al Dominio (`SRV-LINUX01` — Parte 1)
- **Tu guía técnica:** `03-LINUX-INTEGRACION-AD.md`
- **Qué haces en español simple:**
  1. Instalas Ubuntu Server (sin escritorio gráfico, pura terminal, corre rapidísimo) con IP `192.168.50.30` y DNS `192.168.50.10`.
  2. Sincronizas la hora de Linux con la de Windows Server (si se desfasan más de 5 minutos, Kerberos no te deja entrar).
  3. Instalas `realmd` y `sssd`, unes Linux al dominio `redes2.local` (metiéndolo a `OU=Equipos`) y pones la regla `realm permit` para que solo puedan entrar los de `GRP_TI` y `GRP_Desarrollo`.
  4. Pruebas entrar por SSH desde el Windows de Josh usando `rodri.dev` (¡sí entra!) y con `josh.user` (¡lo bota!).
  5. Sacas capturas y guardas el **Snapshot `04-Linux-Unido-AD`**.
- **Cuando termines:** Le pasas la batuta a Leo.

---

### Turno 4: Leo — Los 3 Servicios en Linux (`SRV-LINUX01` — Parte 2)
- **Tu guía técnica:** `04-LINUX-SERVICIOS.md`
- **Qué haces en español simple:**
  Sobre el Ubuntu que ya dejó unido Rodri, montas y pruebas **3 servicios** desde el Windows de Josh:
  1. **Página web (Nginx):** Instalas Nginx, pones un HTML bonito con los nombres del equipo y desde el navegador de Windows abres `http://srv-linux01.redes2.local`.
  2. **Carpeta compartida (Samba):** Creas una carpeta `/srv/samba/compartido` para `GRP_Desarrollo` y desde el Explorador de Windows abres `\\srv-linux01.redes2.local\compartido` con `leo.dev` y creas un archivo de prueba.
  3. **Servidor de archivos FTP (`vsftpd`):** Instalas `vsftpd` (como Linux ya está unido a AD, automáticamente reconoce las cuentas de Windows) y desde Windows te conectas con `ftp srv-linux01.redes2.local` usando `leo.dev` y subes un archivo.
  4. Sacas capturas de todo.

---

### Todo el tiempo + Cierre: Antonio — Arquitecto de Red, Pruebas y el PDF
- **Tu guía técnica:** `05-RED-PRUEBAS-Y-DOCUMENTO.md`
- **Qué haces en español simple:**
  1. **Desde el Día 1:** Armas el Google Docs con el formato exacto que pide el profe, haces el **diagrama de red** (en Draw.io) y redactas Portada, Introducción, Objetivos y Marco Teórico (con citas APA 7 en el texto, incluyendo el link de Red Hat que pasó el profe).
  2. **Cuando todos terminen sus VMs:** Desconectan el internet (Adaptador 2 NAT) de las 3 VMs y corres con todos la **lista de 10 pruebas** (pings, DNS, logins y los 5 servicios) para asegurar que todo jala offline.
  3. Guardan el **Snapshot `05-DEMO-FINAL`** en las 3 VMs.
  4. Revisas que nadie haya olvidado su **Conclusión Individual** (¡vale 20% de la calificación!) ni explicar sus capturas, y exportan el PDF final.

---

## 4. ¿Cómo nos pasamos la batuta con las VMs? (Sin andar cargando 60 GB)

Muchos se preguntan: *"Si Rodri deja montado el Linux, ¿cómo le meto mano yo (Leo) después?"*. Tienen **3 formas**, de la más cómoda a la menos cómoda:

1. **Opción 1 (LA MEJOR — Laptop Maestra + Tailscale / AnyDesk):**
   - **NO se pasan ninguna VM.** Las 3 VMs viven siempre en **la Laptop Maestra** (la compu más potente del equipo que llevarán a exponer).
   - **Joao y Josh (Windows):** Se conectan a la Laptop Maestra por **AnyDesk o RustDesk** para ver las ventanas de Windows.
   - **Rodri y Leo (Linux):** Instalan **Tailscale** (`tailscale.com`, gratis) en la **Laptop Maestra** (host) y en sus propias laptops (¡NO adentro de las VMs!). El dueño de la Laptop Maestra comparte su compu en Tailscale (*Share...*) y en VirtualBox de `SRV-LINUX01` agrega un reenvío de puertos en el Adaptador 2 NAT (`TCP 2222 → 22`). Así Rodri, Leo y sus agentes de IA entran directo por SSH (`ssh -p 2222 ubuntuadmin@<IP-Tailscale>`) desde su casa sobre el mismo Ubuntu, sin quitarle el mouse al dueño.
2. **Opción 2 (Practicar aparte + Juntarse 1–2 horas a integrar):**
   - Durante la semana, Leo prueba Nginx/Samba/vsftpd en su propia laptop y sube sus archivos de config al repo de GitHub.
   - Luego se juntan con la Laptop Maestra y en 30 minutos copian todo al Ubuntu definitivo de Rodri y sacan las capturas finales.
3. **Opción 3 (Exportar `.ova` en USB — solo para Linux si urge):**
   - En VirtualBox: `Archivo → Exportar servicio virtualizado` (`.ova`). Como Ubuntu Server no tiene escritorio gráfico, pesa poquito (~2–4 GB) y sí cabe en una USB. **No hagan esto con las VMs de Windows** porque pesan 15–25 GB.

---

## 5. Las 5 Reglas de Oro para No Cagarla

1. **La hora exacta:** Las 3 máquinas deben tener la misma hora y zona horaria (`UTC-6 México`). Si una se atrasa 5 minutos, Kerberos truena todo.
2. **El DNS es sagrado:** En el Cliente Windows y en Linux, el **único DNS** debe ser `192.168.50.10`. Si les pones `8.8.8.8` o el DNS de tu Wi-Fi, jamás van a encontrar `redes2.local`.
3. **Snapshots SIEMPRE:** Antes de moverle a algo riesgoso, guarda un Snapshot en VirtualBox. Te va a salvar la vida.
4. **Capturas desde el minuto cero:** No dejes las capturas para el final. Cada comando que funcione → captura y a la carpeta `evidencias/`. Y recuerda explicar en el Word **qué hizo cada comando**, porque el profe dijo que pegar solo capturas no cuenta.
5. **Las conclusiones individuales valen 20%:** Es lo mismo que todo el Cliente Windows. Cada quien escribe la suya bien hecha cubriendo los 5 puntos de `05-RED-PRUEBAS-Y-DOCUMENTO.md`.
