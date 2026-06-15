# 06 · Servidor Apache Tomcat

Tomcat es un **contenedor de servlets** Java. Sirve aplicaciones `.war` y páginas `.jsp`.

### Componentes internos

| Componente | Función |
|-----------|---------|
| **Catalina** | Contenedor de servlets (núcleo). Niveles: Engine → Host → Context → Wrapper |
| **Coyote** | Conector HTTP: procesa peticiones y se las pasa a Catalina |
| **Jasper** | Compilador de JSP: convierte `.jsp` en servlets que ejecuta el Wrapper |

---

## Instalación

### 1. Java

```bash
apt-get install default-jdk
update-java-alternatives -l    # Lista versiones instaladas y su ruta
```

### 2. Usuario y grupo dedicado

```bash
# Buena práctica: ejecutar Tomcat con un usuario sin shell de login
groupadd tomcat
mkdir /opt/tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
#   -s /bin/false  → no puede iniciar sesión
#   -g tomcat      → grupo principal
#   -d /opt/tomcat → directorio home
```

### 3. Descargar y descomprimir

```bash
cd /tmp
# Comprobar la versión más reciente en: https://dlcdn.apache.org/tomcat/tomcat-9/
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
tar xvzf apache-tomcat-9.0.112.tar.gz -C /opt/tomcat/ --strip-components=1
```

### 4. Permisos

```bash
chgrp -R tomcat /opt/tomcat/
chmod -R g+r /opt/tomcat/conf
chmod g+x /opt/tomcat/conf
cd /opt/tomcat
chown -R tomcat webapps/ work/ temp/ logs/
```

---

## Servicio systemd

Ver plantilla completa en [`configs/tomcat/tomcat.service`](../configs/tomcat/tomcat.service).

```bash
nano /etc/systemd/system/tomcat.service
systemctl daemon-reload
systemctl start tomcat
systemctl status tomcat
```

```bash
# Rutas equivalentes a /var/www/html en Apache
# /opt/tomcat/webapps   → aquí se despliegan las aplicaciones
# /opt/tomcat/conf/server.xml → puerto (por defecto 8080)
```

---

## Interfaz web de administración

```bash
nano /opt/tomcat/conf/tomcat-users.xml
```

```xml
<role rolename="manager-status"/>   <!-- Estado del servidor -->
<role rolename="manager-gui"/>      <!-- Interfaz web del Manager -->
<role rolename="admin-gui"/>        <!-- Administración de hosts virtuales -->
<user username="miUsuario" password="miPass"
      roles="manager-status,manager-gui,admin-gui"/>
```

### Permitir acceso desde fuera de localhost

```bash
# Comentar el bloque <Valve> en estos dos ficheros:
nano /opt/tomcat/webapps/manager/META-INF/context.xml
nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
nano /opt/tomcat/webapps/examples/META-INF/context.xml
```

---

## Estructura de directorios de una webapp

| Directorio | Acceso | Contenido |
|-----------|--------|-----------|
| `WEB-INF/` | ❌ No accesible desde el navegador | Código compilado, librerías, `web.xml` |
| `META-INF/` | ❌ No accesible desde el navegador | Configuración de Tomcat, `context.xml` |

---

## SSL en Tomcat

### Opción A: keytool (herramienta propia de Java)

```bash
keytool -genkey -alias tomcat -keyalg RSA \
    -keystore /etc/ssl/certs/tomcat.keystore \
    -keysize 2048
# Contraseña: 123456  (¡cambiar en producción!)
# El campo "¿es correcto?" debe responderse con "si"
```

En `server.xml`, añadir el conector HTTPS:

```xml
<!-- Redirigir HTTP → HTTPS -->
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />

<!-- Conector HTTPS con keytool -->
<Connector port="8443"
           protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true"
           scheme="https" secure="true"
           clientAuth="false"
           sslProtocol="TLS"
           keystoreFile="/etc/ssl/certs/tomcat.keystore"
           keystorePass="123456" />
```

### Opción B: convertir certificado OpenSSL a PKCS12

```bash
openssl pkcs12 -export \
    -in  /etc/ssl/certs/apache-selfsigned.crt \
    -inkey /etc/ssl/private/apache-selfsigned.key \
    -out /opt/tomcat/conf/tomcat.p12 \
    -name tomcat

chmod 640 /opt/tomcat/conf/tomcat.p12
chown tomcat:tomcat /opt/tomcat/conf/tomcat.p12
```

```xml
<Connector port="8443"
           protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true"
           scheme="https" secure="true"
           clientAuth="false"
           sslProtocol="TLS"
           keystoreFile="/opt/tomcat/conf/tomcat.p12"
           keystoreType="PKCS12"
           keystorePass="123456" />
```

---

## Logs de Tomcat

| Fichero | Contenido |
|---------|-----------|
| `catalina.out` | Log principal, stdout y stderr del servidor |
| `catalina.<fecha>.log` | Eventos del contenedor Catalina |
| `localhost.<fecha>.log` | Actividad de las apps desplegadas en localhost |
| `localhost_access_log.<fecha>.txt` | Cada petición HTTP recibida |
| `manager.<fecha>.log` | Actividad de la interfaz web Manager |

```bash
cd /opt/tomcat/logs
tail -f catalina.out    # Seguir el log principal en tiempo real
```

---

## Buscar procesos que bloquean puertos (Windows)

```batch
netstat -aon | findstr :8080
netstat -aon | findstr :8005
taskkill /PID <pid> /F
```
