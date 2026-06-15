#!/bin/bash
# instalar-lamp.sh
# Instala el stack LAMP (Apache + MySQL + PHP) y ejecuta la configuración
# mínima de seguridad de MySQL de forma no interactiva.
#
# Uso: sudo bash instalar-lamp.sh

set -e

echo "=== Actualizando repositorios ==="
apt-get update

echo ""
echo "=== Instalando LAMP ==="
apt install -y lamp-server^

echo ""
echo "=== Creando fichero de prueba PHP ==="
cat > /var/www/html/phpinfo.php << 'EOF'
<?php phpinfo(); ?>
EOF
echo "    Acceder a: http://localhost/phpinfo.php"

echo ""
echo "=== Configuración de seguridad de MySQL ==="
echo "    Ejecuta mysql_secure_installation manualmente y responde:"
echo "      Validate password component? → N"
echo "      Change root password?        → N"
echo "      Remove anonymous users?      → Y"
echo "      Disallow root login remotely?→ Y"
echo "      Remove test database?        → Y"
echo "      Reload privilege tables?     → Y"
echo ""
mysql_secure_installation

echo ""
echo "=== LAMP instalado correctamente ==="
echo "    Apache : http://localhost"
echo "    PHP    : http://localhost/phpinfo.php"
echo "    MySQL  : sudo mysql -u root -p"
