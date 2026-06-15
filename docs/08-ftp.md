# 08 · Servidor FTP

---

## Conceptos previos

- FTP **no cifra** la autenticación ni la transferencia. Las credenciales son visibles en texto plano.
- Usa **dos canales**: el puerto 21 para control (comandos) y un puerto dinámico (≥1024) para transferencia de datos.

### Modos de conexión

| Modo | Quién abre el puerto de datos | Compatibilidad con NAT |
|------|-------------------------------|----------------------|
| **Activo** | El servidor conecta al cliente | ❌ Problemático con NAT |
| **Pasivo** | El cliente conecta al servidor | ✅ Recomendado con NAT |

> Con NAT, casi siempre es necesario usar **modo pasivo** porque el router del cliente no acepta conexiones entrantes del servidor.

---

## Cliente FTP en Windows (cmd)

```batch
:: Desactivar firewall para pruebas
netsh advfirewall set allprofiles state off

:: Conectar a servidor público (acceso anónimo)
ftp ftp.gnu.org

:: O de forma interactiva:
ftp
open ftp.gnu.org
```

| Comando | Acción |
|---------|--------|
| `help` | Lista comandos disponibles |
| `ls` | Listar directorio remoto |
| `pwd` | Directorio remoto actual |
| `cd video` | Cambiar directorio remoto |
| `lcd` | Mostrar directorio local actual |
| `lcd C:\Users\usuario\Downloads` | Cambiar directorio local |
| `get fry720.jpg` | Descargar fichero |
| `put fichero.txt` | Subir fichero |
| `bye` | Desconectar |

```batch
:: Reactivar firewall
netsh advfirewall set allprofiles state on
```

---

## FileZilla Cliente

- Instalar y ejecutar **como administrador**.
- Conectar con `Ctrl+S` → Nueva conexión:
  - Servidor: IP o hostname
  - Cifrado: `Usar solo FTP plano (inseguro)` para prácticas sin TLS
  - Acceso: Anónimo (para servidores públicos) o con usuario/contraseña

---

## ProFTPD — servidor FTP en Ubuntu

```bash
apt install proftpd
```

```bash
nano /etc/proftpd/proftpd.conf
```

```apache
Port 21                         # Puerto de control

# Descomenta para modo pasivo (abrir también en el firewall)
PassivePorts 1024 1025

# Encerrar a cada usuario en su home
DefaultRoot ~

# O redirigir a un directorio concreto
# DefaultRoot /var/www/

# Permisos sobre el directorio compartido
<Directory /var/www/*>
    AllowOverwrite on
    <Limit ALL>
        AllowAll
    </Limit>
</Directory>
```

```bash
sudo systemctl restart proftpd
sudo systemctl status proftpd
```

### Firewall (si está activo ufw)

> ⚠️ Si habilitas `ufw`, cierra todos los puertos — incluyendo el 80 de Apache.

```bash
ufw allow 21/tcp
ufw allow 1024:1025/tcp
ufw enable
ufw status
# Tras las pruebas:
ufw disable
```

---

## Conectar FileZilla con ProFTPD (adaptador puente)

```bash
ip a    # Ver IP de Ubuntu, ej. 192.168.1.11
```

En FileZilla → `Ctrl+S` → Nueva conexión:
- Servidor: `192.168.1.11`
- Acceso: Preguntar contraseña
- Usuario: `dlariosb` (usuario del sistema Ubuntu)
- Cifrado: Usar solo FTP plano

---

## ProFTPD con NAT

```apache
# En proftpd.conf, descomentar:
MasqueradeAddress 127.0.0.1     # Enmascara la IP real con 127.0.0.1
```

En FileZilla:
- Servidor: `127.0.0.1`
- Mapear los puertos 21 y los pasivos en VirtualBox

---

## Cliente FTP en Ubuntu

```bash
ftp 192.168.56.1               # Conectar con XAMPP FileZilla Server en Windows
# Usuario: anonimo
# Password: (vacío)

lcd /etc/apache2/sites-available    # Ir al directorio local
lpwd                                # Ver directorio local actual
put 000-default.conf                # Subir fichero
get prueba.conf                     # Descargar fichero
```
