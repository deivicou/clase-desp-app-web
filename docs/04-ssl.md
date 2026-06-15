# 04 · Certificado SSL con OpenSSL

Un certificado **autofirmado** no es reconocido por los navegadores como de confianza (no lo ha firmado una CA). Útil para desarrollo y prácticas.

---

## Instalación y generación del certificado

```bash
apt install openssl
a2enmod ssl
```

```bash
# Genera clave privada (.key) y certificado público (.crt) válido 365 días
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt
```

Datos solicitados durante la generación:

| Campo | Código | Valor de ejemplo |
|-------|--------|-----------------|
| País | C | `es` |
| Provincia | ST | `Extremadura` |
| Ciudad | L | `plasencia` |
| Empresa | O | `IES Valle` |
| Departamento | OU | `IES Valle` |
| Dominio / CN | CN | `localhost` |
| Admin email | — | `david@ies.com` |

> ⚠️ El navegador contrasta que el **CN** del certificado coincida con el dominio del `ServerName`.

---

## VirtualHost HTTPS (puerto 443)

Ver plantilla en [`configs/apache/virtualhost-ssl.conf`](../configs/apache/virtualhost-ssl.conf).

```bash
nano /etc/apache2/sites-available/site_ssl.conf
```

```apache
<VirtualHost *:443>
    ServerAdmin admin@your_domain.com
    ServerName your_domain.com

    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /etc/ssl/certs/apache-selfsigned.crt    # Clave pública
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key  # Clave privada

    # Permite que Apache pase variables SSL a CGI/PHP
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>

    # Los scripts CGI en Linux se ejecutan aquí
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    ErrorLog  ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

```bash
sudo a2ensite site_ssl.conf
systemctl reload apache2
```

---

## Script de generación rápida

Ver [`configs/ssl/generar-certificado.sh`](../configs/ssl/generar-certificado.sh) para un script que automatiza el proceso completo.
