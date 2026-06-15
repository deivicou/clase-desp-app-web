#!/bin/bash
# instalar-bind9.sh
# Instala Bind9 y despliega una zona de ejemplo (ejemplo.com).
#
# Uso: sudo bash instalar-bind9.sh

set -e

echo "=== Instalando Bind9 ==="
apt-get update
apt-get install -y bind9 bind9utils

echo ""
echo "=== Copiando configuración de opciones ==="
# Si existe el fichero en el repositorio, copiarlo; si no, crear uno mínimo
if [ -f "configs/bind9/named.conf.options" ]; then
    cp configs/bind9/named.conf.options /etc/bind/named.conf.options
else
    cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";
    forwarders { 8.8.8.8; 1.1.1.1; };
    allow-query { any; };
    allow-transfer { none; };
    listen-on port 53 { any; };
    dnssec-validation auto;
};
EOF
fi

echo ""
echo "=== Desplegando zona ejemplo.com ==="
if [ -f "configs/bind9/db.zona-ejemplo" ]; then
    cp configs/bind9/db.zona-ejemplo /etc/bind/db.ejemplo
    cp configs/bind9/db.zona-inversa /etc/bind/db.127.0.0
fi

cat >> /etc/bind/named.conf.local << 'EOF'

zone "ejemplo.com" {
    type master;
    file "/etc/bind/db.ejemplo";
};

zone "0.0.127.in-addr.arpa" {
    type master;
    file "/etc/bind/db.127.0.0";
};
EOF

echo ""
echo "=== Comprobando sintaxis ==="
named-checkconf
named-checkzone ejemplo.com /etc/bind/db.ejemplo
named-checkzone 0.0.127.in-addr.arpa /etc/bind/db.127.0.0

echo ""
echo "=== Iniciando Bind9 ==="
systemctl restart bind9
systemctl enable  bind9
systemctl status  bind9 --no-pager

echo ""
echo "=== Bind9 instalado correctamente ==="
echo "    Verificar zona directa  : nslookup ejemplo.com 127.0.0.1"
echo "    Verificar zona inversa  : nslookup 127.0.0.1 127.0.0.1"
echo "    Logs                    : journalctl -u bind9 -f"
