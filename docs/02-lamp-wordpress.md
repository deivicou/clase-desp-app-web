# 02 · Servidor LAMP y WordPress

**LAMP** = Linux + Apache + MySQL + PHP

---

## Instalación de LAMP

```bash
sudo apt install lamp-server^
```

### Verificar PHP

```bash
# Crear fichero de prueba
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
# Abrir en el navegador: http://localhost/phpinfo.php
```

---

## Configuración de MySQL

```bash
mysql_secure_installation
```

Opciones recomendadas durante la configuración:

| Pregunta | Respuesta | Motivo |
|----------|-----------|--------|
| Validate password component? | `N` | Sin requisitos de contraseña complejos |
| Change root password? | `N` | Por defecto usa `auth_socket` (sudo del sistema) |
| Remove anonymous users? | `Y` | Elimina acceso sin autenticación |
| Disallow root login remotely? | `Y` | Seguridad básica |
| Remove test database? | `Y` | Limpieza |
| Reload privilege tables? | `Y` | Aplica los cambios |

### Restablecer contraseña de root (si se pierde)

```bash
sudo systemctl stop mysql
sudo mysqld_safe --skip-grant-tables &
mysql -u root
```
```sql
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'nueva_contraseña';
```
```bash
sudo systemctl stop mysql
sudo systemctl start mysql
```

---

## Preparar la base de datos para WordPress

```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE wordpress_db;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON wordpress_db.* TO 'wp_user'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;

-- Verificaciones
SELECT user FROM mysql.user;   -- Debe aparecer wp_user@localhost
SHOW DATABASES;                -- Debe aparecer wordpress_db

EXIT;
```

---

## Instalación de WordPress

```bash
# Descargar
cd /tmp && wget https://wordpress.org/latest.tar.gz

# Descomprimir
tar -xvf latest.tar.gz

# Crear directorio y copiar ficheros
mkdir /var/www/wordpress
cp -R wordpress/* /var/www/wordpress

# Permisos
chown -R www-data:www-data /var/www/wordpress/
chmod -R 755 /var/www/wordpress/
mkdir /var/www/wordpress/wp-content/uploads
chown -R www-data:www-data /var/www/wordpress/wp-content/uploads/
```

### VirtualHost para WordPress

```bash
nano /etc/apache2/sites-available/wordpress.conf
```

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/wordpress
</VirtualHost>
```

```bash
a2ensite wordpress.conf
nano /etc/apache2/ports.conf   # Asegurarse de que escucha en el puerto correcto
systemctl reload apache2
```

Acceder en el navegador a `http://localhost/` y completar el asistente de instalación.

> 📌 Referencia: [DigitalOcean — Install WordPress on Ubuntu](https://www.digitalocean.com/community/tutorials/install-wordpress-on-ubuntu)
