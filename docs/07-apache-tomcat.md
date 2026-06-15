# 07 · Integración Apache ↔ Tomcat

Apache actúa como **proxy inverso** frente a Tomcat: recibe las peticiones HTTP/HTTPS y las reenvía a Tomcat, ocultando la infraestructura al cliente.

---

## Opción A: ProxyPass (módulo proxy_http)

Método más sencillo y recomendado para la mayoría de casos.

```bash
a2enmod proxy
a2enmod proxy_http
```

```bash
nano /etc/apache2/sites-available/jsp.conf
```

```apache
<VirtualHost *:801>

    # Redirige /examples al contexto de Tomcat
    # Importante: usar la misma ruta en origen y destino para evitar
    # problemas con URLs absolutas dentro de la app
    ProxyPass        /examples http://localhost:8080/examples/jsp/
    ProxyPassReverse /examples http://localhost:8080/examples/jsp/

    # Para redirigir a HTTPS de Tomcat:
    # ProxyPass        / https://localhost:8443/
    # ProxyPassReverse / https://localhost:8443/
    # SSLProxyEngine On          # Habilita proxy inverso SSL
    # SSLProxyVerify none        # No valida el certificado autofirmado
    # SSLProxyCheckPeerCN off    # No valida CN del certificado
    # SSLProxyCheckPeerName off  # Complementa la anterior

</VirtualHost>
```

```bash
a2ensite jsp.conf
nano /etc/apache2/ports.conf    # Añadir: Listen 801
service apache2 reload
```

> 💡 Acceder a `http://localhost:50007/examples/` — importante incluir la barra final (diferencia entre directorio y fichero).

---

## Opción B: mod_jk (protocolo AJP)

Más complejo y configurable. Permite **balanceo de carga** entre múltiples instancias de Tomcat.

```bash
apt-get install libapache2-mod-jk
sudo a2enmod jk
```

### Configurar workers

```bash
nano /etc/libapache2-mod-jk/workers.properties
```

```properties
worker.list=ajp13_worker

# Tipo de protocolo AJP 1.3
worker.ajp13_worker.type=ajp13
worker.ajp13_worker.host=localhost
worker.ajp13_worker.port=8009

# Factor de balanceo de carga (número de peticiones que recibe este servidor)
worker.ajp13_worker.lbfactor=1
```

```bash
# Verificar que la ruta del fichero workers es correcta
nano /etc/apache2/mods-available/jk.conf
```

### VirtualHost con mod_jk

```bash
nano /etc/apache2/sites-available/000-default.conf
```

```apache
<VirtualHost *:80>
    # Redirige todas las peticiones al worker AJP
    JkMount /* ajp13_worker
    # Alternativa para solo JSP:
    # JkMount /jsp/* ajp13_worker
</VirtualHost>
```

### Habilitar conector AJP en Tomcat

```bash
nano /opt/tomcat/conf/server.xml
```

```xml
<!-- Descomentar y añadir secretRequired="false" -->
<Connector port="8009" protocol="AJP/1.3"
           redirectPort="8443"
           secretRequired="false"/>
```

### Solución a errores de permisos en Tomcat

```bash
# Si catalina.out muestra errores al crear directorios:
sudo chown -R tomcat:tomcat /opt/tomcat
```
