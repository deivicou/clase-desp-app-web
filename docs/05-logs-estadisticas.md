# 05 · Logs y Estadísticas en Apache

---

## Ficheros de log

| Fichero | Contenido |
|---------|-----------|
| `/var/log/apache2/error.log` | Errores del servidor |
| `/var/log/apache2/access.log` | Todas las peticiones recibidas |

```bash
nano /var/log/apache2/error.log
nano /var/log/apache2/access.log

# Seguir el log en tiempo real
tail -f /var/log/apache2/access.log
```

> 💡 Con NAT, las peticiones desde Windows aparecen en `access.log` con la IP `10.0.2.2`.

---

## mod_status — estadísticas del servidor

```bash
a2enmod status
```

### Opción A: usar el VirtualHost por defecto

```bash
# Comentar la restricción de IP en el fichero de configuración del módulo
nano /etc/apache2/mods-enabled/status.conf
# Comentar las líneas "Require ip ..."
```

Acceder en el navegador a `http://localhost/server-status`.

### Opción B: exponer estadísticas en un VirtualHost propio

```apache
<VirtualHost *:800>
    DocumentRoot /var/www/html

    <Location /estadisticas>
        SetHandler server-status    # Asocia la URL al módulo status
                                    # El directorio /estadisticas no tiene que existir físicamente
    </Location>
</VirtualHost>
```

---

## mod_info — información de configuración

```bash
a2enmod info
nano /etc/apache2/mods-enabled/info.conf
# Acceder a: http://localhost/server-info
```

---

## Truco: simular DNS con /etc/hosts para pruebas de VirtualHost

```bash
nano /etc/hosts
# Añadir:
127.0.0.1 google.com    # Las peticiones a google.com apuntarán al servidor local
```

```bash
curl google.com          # Responde el Apache local, no Google
```
