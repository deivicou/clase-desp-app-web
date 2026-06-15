#!/bin/bash
# generar-certificado.sh
# Genera un certificado SSL autofirmado con OpenSSL y habilita el módulo SSL en Apache.
#
# Uso: sudo bash generar-certificado.sh

set -e

echo "=== Instalando OpenSSL ==="
apt install -y openssl

echo ""
echo "=== Habilitando módulo SSL en Apache ==="
a2enmod ssl

echo ""
echo "=== Generando clave privada y certificado autofirmado ==="
echo "    Válido 365 días · RSA 2048 bits"
echo ""

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out    /etc/ssl/certs/apache-selfsigned.crt

echo ""
echo "=== Ficheros generados ==="
echo "    Clave privada : /etc/ssl/private/apache-selfsigned.key"
echo "    Certificado   : /etc/ssl/certs/apache-selfsigned.crt"
echo ""
echo "=== Siguiente paso ==="
echo "    Copiar configs/apache/virtualhost-ssl.conf a /etc/apache2/sites-available/"
echo "    y ejecutar: a2ensite virtualhost-ssl.conf && systemctl reload apache2"
