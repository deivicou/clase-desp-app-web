# 03 · Seguridad y Login en Apache

---

## Autenticación Basic (sin cifrado)

> ⚠️ Las credenciales viajan en texto plano. Verificable con Wireshark.

```bash
apt-get install apache2-utils

# Crear fichero de contraseñas (-c solo la primera vez)
htpasswd -c /etc/apache2/passwd profesor1
htpasswd /etc/apache2/passwd profesor2    # Añadir más usuarios

a2enmod auth_basic
```

```apache
<VirtualHost *:84>
    <Directory /var/www/profesor>
        Options Indexes FollowSymLinks
        AllowOverride None
        AuthType Basic
        AuthName "Acceso restringido"
        AuthUserFile /etc/apache2/passwd
        Require valid-user
    </Directory>
</VirtualHost>
```

---

## Autenticación Digest (con cifrado MD5)

> ✅ La contraseña no viaja en texto plano. Comprobable con Wireshark.

```bash
a2ensite auth_digest

# Crear fichero de contraseñas digest (-c solo la primera vez)
htdigest -c /etc/apache2/pass_dig grupo usuario
htdigest /etc/apache2/pass_dig grupo usuario   # Añadir más usuarios
```

```apache
<Directory /var/www/html/profesor_dig>
    Options Indexes FollowSymLinks
    AllowOverride None
    AuthType Digest
    AuthName grupo                              # Debe coincidir con el grupo del htdigest
    AuthDigestProvider file
    AuthUserFile /etc/apache2/pass_dig
    Require valid-user
</Directory>
```

---

## Control de acceso por IP

Las directivas `Order`, `Allow` y `Deny` están **obsoletas**. Usar `Require`:

```apache
<Directory /var/www/html>
    Require all denied              # Base: todo denegado
    Require ip 192.168.1.0/24       # Permite rango de red
    Require ip 127.0.0.1            # Permite IP concreta
    Require not ip 192.168.1.50     # Excepción dentro del rango
</Directory>
```

> 💡 Con NAT, la IP del host Windows vista desde Ubuntu es `10.0.2.2` (IP del adaptador NAT de VirtualBox).

### Combinar autenticación con control por IP

```apache
<Directory /var/www/html/profesor_dig>
    AuthType Digest
    AuthName grupo
    AuthDigestProvider file
    AuthUserFile /etc/apache2/pass_dig
    Require ip 10.0.2.2        # Solo accesible desde fuera de la VM
    Require valid-user
</Directory>
```

---

## Ejemplo completo: Escape Room

Ejercicio que combina varias directivas:

```apache
<VirtualHost *:8X>
    DocumentRoot /var/www/EscapeRoom

    <Directory /var/www/EscapeRoom>
        Options Indexes
    </Directory>

    # Opción 1: solo accesible desde localhost
    <Directory /var/www/EscapeRoom/Opcion1>
        DirectoryIndex contrasena.html
        Require local
    </Directory>

    # Opción 2: protegida con Digest
    <Directory /var/www/EscapeRoom/Opcion2>
        DirectoryIndex alias.html
        AuthType Digest
        AuthName grupo
        AuthDigestProvider file
        AuthUserFile /etc/apache2/pass_dig
        Require valid-user
    </Directory>

    # Opción 3: sin índice + error personalizado + puerta trasera
    <Directory /var/www/EscapeRoom/Opcion3>
        Options -Indexes
        ErrorDocument 403 /Opcion3/error.html
    </Directory>

    <Directory /var/www/EscapeRoom/Opcion3/Puerta>
        Require all denied
    </Directory>

    <Directory /var/www/EscapeRoom/Opcion3/Puerta/Trasera>
        Options -Indexes
        Require all granted
    </Directory>

    Alias /backdoor /var/www/EscapeRoom/Opcion3/Puerta/Trasera/backdoor.html
    Redirect /Opcion3/Puerta/Trasera https://chatgpt.com
    Redirect /Opcion4 https://chatgpt.com
</VirtualHost>

# VirtualHost para server-info (solo desde fuera)
<VirtualHost *:8X>
    <Location /secreto>
        SetHandler server-info
        Require ip 10.0.2.2
    </Location>
</VirtualHost>
```
