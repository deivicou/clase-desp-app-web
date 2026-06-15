# 00 · Herramientas y utilidades generales

Comandos de uso frecuente en el día a día de la asignatura.

---

## Consola y teclado

```bash
# Aumentar tamaño de fuente en la consola
nano /etc/default/console-setup
# Cambiar: FONTSIZE="16x32"
setupcon

# Configurar teclado en español
dpkg-reconfigure keyboard-configuration
reboot
```

---

## Nano

```bash
# Activar números de línea
nano ~/.nanorc
# Añadir:  set linenumbers
```

| Atajo | Acción |
|-------|--------|
| `Ctrl + k` | Cortar línea |
| `Alt + 6` | Copiar línea |
| `Ctrl + u` | Pegar |

---

## Screen — sesiones persistentes

Útil para dejar procesos corriendo (p. ej. el túnel de Cloudflare) aunque se cierre la terminal.

```bash
apt install screen

screen                  # Crea una nueva sesión
Ctrl+a [                # Entra en modo copia (permite hacer scroll)
Esc                     # Sale del modo copia
exit                    # Cierra la sesión screen actual
Ctrl+a d                # Detach: deja la sesión corriendo en segundo plano

screen -ls              # Lista sesiones activas
killall screen          # Mata todas las sesiones
```

> **Alternativa:** escritorios TTY virtuales con `Ctrl+Alt+F1`, `Ctrl+Alt+F2`, etc.

---

## Red

```bash
ip a                    # Muestra interfaces y direcciones IP
```

---

## Intercambio de ficheros entre Windows y Ubuntu

Aprovechando Apache como servidor HTTP para transferir archivos entre host y VM.

### De Ubuntu → Windows

El fichero debe estar en `/var/www/html`. Ejecutar desde **cmd de Windows**:

```batch
curl -o "C:\Users\usuario\Downloads\fichero.html" "http://localhost:50000/fichero.html"
```

### De Windows → Ubuntu

El fichero debe estar en `C:\xampp\htdocs` (Apache XAMPP) o `C:\xampp\tomcat\webapps\ROOT` (Tomcat XAMPP). Ejecutar desde **Ubuntu**:

```bash
# Desde Apache XAMPP (puerto 80)
curl -o /destino/en/ubuntu/fichero.conf 192.168.56.1:80/fichero.conf

# Desde Tomcat XAMPP (puerto 8080)
curl -o /etc/systemd/system/tomcat.service 192.168.56.1:8080/tomcat.service
```

---

## Ejemplos de práctica de conectividad

```bash
curl 192.168.56.1:8080          # Conectar con Tomcat en Windows
curl 192.168.56.1:80/dashboard/ # Conectar con Apache en Windows
```
