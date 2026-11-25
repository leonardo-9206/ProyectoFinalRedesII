# Protocolo Obligatorio para Agentes de IA (Antigravity / Claude / Gemini)

> **Si eres un agente de IA ayudando a Joao, Josh, Rodri, Leo o Antonio en este proyecto, sigue estas reglas en TODO momento.**

---

## 1. Regla de Oro: Modo Copiloto Paso a Paso

1. **NO avientes bloques gigantes de 15 comandos de golpe** (a menos que el usuario lo pida). Guía al estudiante **paso por paso** (1 o 2 acciones a la vez), esperando a que confirme el resultado o te pase captura/salida de terminal.
2. **Avisa explícitamente cuándo tomar capturas de pantalla:** Cada vez que el paso corresponda a una evidencia del checklist de su guía (`docsprivados/0X-*.md`), díselo de forma muy visible:
   > 📸 **CAPTURA OBLIGATORIA:** Toma captura de esto ahora y guárdala como `evidencias/<carpeta>/<nombre>.png`.
3. **Respeta al 100% `docsprivados/00-ARQUITECTURA-Y-ESTANDARES.md`:** Nunca cambies IPs (`192.168.50.10/.20/.30`), dominio (`redes2.local`), NetBIOS (`REDES2`), OUs, grupos ni usuarios sin que el equipo lo acuerde explícitamente.

---

## 2. Regla de Auto-Bitácora (Registro Automático para el Informe PDF)

El docente exige que **cada procedimiento** del informe incluya 8 elementos (propósito, requisitos previos, pasos cronológicos, comandos explicados, archivos modificados, capturas, pruebas y errores/soluciones).

Para que el estudiante no pierda nada ni tenga que reconstruir todo al final:

1. **Crea o actualiza automáticamente el archivo de bitácora del integrante** en la carpeta `bitacoras/`:
   - Joao → `bitacoras/01-joao-ad.md`
   - Josh → `bitacoras/02-josh-winclient.md`
   - Rodri → `bitacoras/03-rodri-linux-ad.md`
   - Leo → `bitacoras/04-leo-linux-servicios.md`
   - Antonio → `bitacoras/05-antonio-pruebas.md`
2. **Cada vez que se complete un paso importante o se resuelva un error**, registra automáticamente en esa bitácora:
   - **Procedimiento y propósito** (en lenguaje técnico formal, listo para el PDF).
   - **Comandos ejecutados** y una breve explicación de para qué sirvió cada uno.
   - **Archivos modificados** (con los cambios exactos aplicados).
   - **Captura tomada** (referencia al nombre de archivo en `evidencias/...`, ej. `Figura X — evidencias/04-linux-servicios/02-nginx-prueba-win.png`).
   - **Prueba realizada y resultado obtenido.**
   - **Errores encontrados y cómo se resolvieron** *(esto también le servirá al estudiante para su Conclusión Individual del 20%)*.
3. **Si estás trabajando en modo chat sin acceso directo a archivos**, entrega al final de cada bloque completado un recuadro `### Registro de Bitácora (copiar a bitacoras/0X-....md)` para que el estudiante solo lo copie y pegue.

---

## 3. Trabajo Remoto sobre la Laptop Maestra (Tailscale + AnyDesk)

Las 3 VMs definitivas viven en **una sola Laptop Maestra**. Al iniciar a trabajar con cualquier integrante, **recuérdale/verifica su acceso remoto** antes de empezar:

- **Para Joao y Josh (VMs Windows gráficas):** Usar **AnyDesk** o **RustDesk** hacia la Laptop Maestra.
- **Para Rodri y Leo (VM Linux `SRV-LINUX01`) — Acceso directo por SSH con Tailscale:**
  1. Indicarle al equipo que instale **Tailscale** (`tailscale.com`) en el **sistema anfitrión (host)** de la **Laptop Maestra**, la laptop de **Rodri** y la laptop de **Leo**.
     > **IMPORTANTE:** Tailscale va en las **laptops físicas (host)**, **NUNCA** adentro de las VMs (para no interferir con la red interna `intnet-redes2`).
  2. El dueño de la Laptop Maestra comparte su equipo desde `login.tailscale.com` (3 puntitos → *Share...*) con Rodri y Leo, y les pasa su IP Tailscale (`100.x.x.x`).
  3. En la Laptop Maestra, en VirtualBox (`SRV-LINUX01` → Configuración → Red → **Adaptador 2 `NAT`** → Avanzado → **Reenvío de puertos**), crear la regla:
     - **Protocolo:** `TCP` | **Puerto anfitrión:** `2222` | **Puerto invitado:** `22` *(IPs vacías)*.
  4. **Conexión SSH del integrante o del agente de IA:**
     - Si el agente corre en la **Laptop Maestra**: `ssh -p 2222 ubuntuadmin@127.0.0.1`
     - Si el agente corre en la **laptop de Rodri o Leo**: `ssh -p 2222 ubuntuadmin@<IP-Tailscale-Laptop-Maestra>`
  5. **Recordatorio:** Aunque el agente ejecute o depure comandos por SSH, SIEMPRE pedirle al estudiante que tome las capturas de pantalla obligatorias (`📸 CAPTURA OBLIGATORIA`) antes de avanzar al siguiente paso.
