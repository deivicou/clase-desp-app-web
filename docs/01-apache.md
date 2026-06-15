# 01 · Instalación y configuración de Apache

---

## Instalación

```bash
apt-get install apache2
apt install curl        # Para probar páginas desde terminal
```

---

## Gestión del servicio

```bash
service apache2 status
service apache2 start
service apache2 stop
service apache2 restart
service apache2 reload  # Recarga config sin cortar conexiones activas

# Equivalentes con systemctl
systemctl restart apache2
systemctl reload apache2

apache2ctl -t           # Comprueba la sintaxis de la configuración (debug)
```

---

## Rutas importantes

| Ruta | Descripción |
|------|-------------|
| `/var/www/html` | Directorio raíz por defecto |
| `/etc/apache2/ports.conf` | Puertos en escucha |
| `/etc/apache2/sites-available/` | VirtualHosts disponibles |
| `/etc/apache2/sites-enabled/` | VirtualHosts activos (symlinks) |
| `/etc/apache2/mods-available/` | Módulos disponibles |

---

## VirtualHost — configuración completa

Ver plantilla en [`configs/apache/virtualhost-basico.conf`](../configs/apache/virtualhost-basico.conf).

```apache
<VirtualHost *:80>

    ServerName example.com              # Nombre del servidor (para balanceo de carga)
    ServerAdmin webmaster@localhost     # Email del administrador
    DocumentRoot /var/www/example       # Directorio raíz del sitio

    DirectoryIndex index.html           # Fichero que se sirve por defecto

    Alias /directorio /var/www/         # Reescritura de URL (abreviatura)
    Redirect /torre http://www.torrespacio.com  # Redirección externa

    <Directory /var/www/example>
        Options -Indexes                # Desactiva listado de directorios
        Options FollowSymLinks          # Permite seguir enlaces simbólicos
        AllowOverride None              # Ignora ficheros .htaccess

        # Control de acceso
        Require all granted             # Permite todo
        Require all denied              # Deniega todo
        Require ip 127.0.0.1            # Solo permite esa IP
        Require not ip 192.168.0.12     # Deniega esa IP
    </Directory>

    # Mensajes de error personalizados
    ErrorDocument 404 "Página no encontrada"
    ErrorDocument 404 /error/no_encontrado.html
    ErrorDocument 403 "No tienes permiso para acceder"

</VirtualHost>
```

### Crear enlace simbólico para test de FollowSymLinks

```bash
mkdir /var/www/html/oculto
echo "contenido secreto" > /var/www/html/oculto/archivo.txt
ln -s /var/www/html/oculto enlace
```

### Activar / desactivar VirtualHosts

```bash
a2ensite nombre.conf
a2dissite nombre.conf
systemctl reload apache2
```

---

## Módulos

```bash
a2enmod  nombre     # Habilita un módulo
a2dismod nombre     # Deshabilita un módulo

ls /etc/apache2/mods-available   # Ver módulos disponibles
```

---

## UserDir — web por usuario

Permite que cada usuario del sistema publique en `~/public_html` y acceda vía `http://servidor/~usuario`.

```bash
a2enmod userdir
# (Para deshabilitar)
a2dismod userdir

# Dar permisos al directorio del usuario
chmod 755 /home/dlariosb
curl http://localhost/~dlariosb/ejercicio6.html
```

---

## Truco: simular DNS con /etc/hosts

Antes de tener DNS real, se puede falsear la resolución editando el fichero `hosts`:

```bash
nano /etc/hosts
# Añadir:
127.0.0.1 google.com   # El SO consulta este fichero ANTES que el DNS
```

```bash
# En Windows:
# C:\Windows\System32\drivers\etc\hosts
```

> ⚠️ Recuerda deshacer el cambio cuando termines la prueba.
