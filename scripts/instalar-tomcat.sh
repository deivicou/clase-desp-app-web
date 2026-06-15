#!/bin/bash
# instalar-tomcat.sh
# Descarga e instala Apache Tomcat 9 con usuario dedicado y servicio systemd.
#
# Uso: sudo bash instalar-tomcat.sh

set -e

TOMCAT_VERSION="9.0.112"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

echo "=== Instalando Java ==="
apt-get update
apt-get install -y default-jdk

echo ""
echo "=== Creando usuario y grupo tomcat ==="
groupadd --force tomcat
mkdir -p /opt/tomcat
id -u tomcat &>/dev/null || \
    useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

echo ""
echo "=== Descargando Tomcat ${TOMCAT_VERSION} ==="
cd /tmp
wget -q --show-progress "${TOMCAT_URL}"

echo ""
echo "=== Descomprimiendo en /opt/tomcat ==="
tar xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" -C /opt/tomcat/ --strip-components=1

echo ""
echo "=== Aplicando permisos ==="
chgrp -R tomcat /opt/tomcat/
chmod -R g+r    /opt/tomcat/conf
chmod g+x       /opt/tomcat/conf
chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ \
                /opt/tomcat/temp/    /opt/tomcat/logs/

echo ""
echo "=== Instalando servicio systemd ==="
JAVA_HOME=$(update-java-alternatives -l | awk '{print $3}' | head -1)

cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
Environment=JAVA_HOME=${JAVA_HOME}
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat-pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "=== Iniciando Tomcat ==="
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat
systemctl status tomcat --no-pager

echo ""
echo "=== Tomcat instalado correctamente ==="
echo "    Interfaz web: http://localhost:8080"
echo "    Editar usuarios: /opt/tomcat/conf/tomcat-users.xml"
echo "    Ver logs:        tail -f /opt/tomcat/logs/catalina.out"
