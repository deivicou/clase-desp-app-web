# 🌐 Despliegue de Aplicaciones Web (DAW2)

> Apuntes y configuraciones del módulo de **Despliegue de Aplicaciones Web**

Repositorio de referencia con comandos, configuraciones y notas organizados por temas. Todos los snippets están probados en **Ubuntu Server** con adaptador NAT/Puente sobre VirtualBox.

---

## 📂 Estructura

```
clase-desp-app-web/
├── README.md
├── docs/
│   ├── 00-herramientas.md       # Utilidades generales (nano, screen, curl...)
│   ├── 01-apache.md             # Instalación y configuración de Apache
│   ├── 02-lamp-wordpress.md     # Servidor LAMP y WordPress
│   ├── 03-seguridad-login.md    # Autenticación Basic, Digest y control de acceso
│   ├── 04-ssl.md                # Certificados SSL con OpenSSL
│   ├── 05-logs-estadisticas.md  # Logs y módulo status/info
│   ├── 06-tomcat.md             # Instalación y configuración de Tomcat
│   ├── 07-apache-tomcat.md      # Integración Apache ↔ Tomcat (proxy y mod_jk)
│   ├── 08-ftp.md                # Servidor FTP con ProFTPD
│   ├── 09-dns.md                # Servidor DNS con Bind9
│   └── 10-cloudflare-tunnel.md  # Túnel Cloudflare
├── configs/
│   ├── apache/
│   │   ├── virtualhost-basico.conf
│   │   ├── virtualhost-ssl.conf
│   │   ├── auth-basic.conf
│   │   ├── auth-digest.conf
│   │   └── proxy-tomcat.conf
│   ├── tomcat/
│   │   ├── tomcat.service
│   │   ├── tomcat-users.xml
│   │   └── server-ssl.xml
│   ├── bind9/
│   │   ├── named.conf.options
│   │   ├── named.conf.local
│   │   ├── db.zona-ejemplo
│   │   └── db.zona-inversa
│   ├── ftp/
│   │   └── proftpd.conf
│   └── ssl/
│       └── generar-certificado.sh
└── scripts/
    ├── instalar-lamp.sh
    ├── instalar-tomcat.sh
    └── instalar-bind9.sh
```

---

## 🗺️ Índice de temas

| # | Tema | Descripción |
|---|------|-------------|
| 00 | [Herramientas](docs/00-herramientas.md) | Nano, screen, curl, intercambio de ficheros |
| 01 | [Apache](docs/01-apache.md) | Instalación, VirtualHosts, Directory, Alias |
| 02 | [LAMP + WordPress](docs/02-lamp-wordpress.md) | MySQL, PHP, WordPress |
| 03 | [Seguridad y Login](docs/03-seguridad-login.md) | Basic, Digest, control por IP |
| 04 | [SSL](docs/04-ssl.md) | Certificados autofirmados con OpenSSL |
| 05 | [Logs y Estadísticas](docs/05-logs-estadisticas.md) | mod_status, mod_info, access.log |
| 06 | [Tomcat](docs/06-tomcat.md) | Instalación, servicio, SSL con keytool |
| 07 | [Apache ↔ Tomcat](docs/07-apache-tomcat.md) | ProxyPass y mod_jk |
| 08 | [FTP](docs/08-ftp.md) | ProFTPD, modos activo/pasivo, FileZilla |
| 09 | [DNS](docs/09-dns.md) | Bind9, zonas, resolución inversa, maestro/esclavo |
| 10 | [Cloudflare Tunnel](docs/10-cloudflare-tunnel.md) | Exposición pública sin abrir puertos |

---

## ⚙️ Entorno de trabajo

- **SO:** Ubuntu Server 22.04 LTS
- **Virtualización:** VirtualBox (NAT + Adaptador Puente)
- **Red NAT:** la IP de Windows vista desde Ubuntu es `10.0.2.2`
- **Red Puente:** usar `ip a` para ver la IP asignada

---

## 🔗 Referencias

- [Documentación Apache](https://httpd.apache.org/docs/)
- [Documentación Tomcat 9](https://tomcat.apache.org/tomcat-9.0-doc/)
- [Documentación Bind9](https://bind9.readthedocs.io/)
- [DigitalOcean: WordPress en Ubuntu](https://www.digitalocean.com/community/tutorials/install-wordpress-on-ubuntu)
- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
