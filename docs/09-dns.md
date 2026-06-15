# 09 · Servidor DNS con Bind9

---

## Conceptos clave

### Jerarquía DNS

```
.org          → 1er nivel (TLD): red de servidores raíz
debian        → 2º nivel: nombre que identifica la página
www.          → 3er nivel: subdominio que apunta al servidor concreto
```

### Tipos de servidor DNS

| Tipo | Descripción |
|------|-------------|
| **Primario (maestro)** | Tiene autoridad sobre su zona: crea, edita y borra registros |
| **Secundario (esclavo)** | Copia del primario (transferencia de zona). Balanceo y redundancia |
| **Caché** | Almacena respuestas para acelerar consultas repetidas |

### Resolución de nombres — orden de búsqueda

1. Fichero local `/etc/hosts`
2. Servidor DNS configurado:
   - 2.1. Caché o base de datos propia del DNS
   - 2.2. Consulta a otro DNS:
     - **Recursiva:** el DNS va preguntando a otros DNS hasta obtener respuesta
     - **Iterativa:** el DNS responde "pregunta a este otro DNS"

### Resolución inversa

El dominio especial `.arpa` (subdominio `in-addr`) permite obtener el nombre de dominio a partir de una IP:

```
5.0.168.192.in-addr.arpa  →  (IP invertida del registro PTR)
```

---

## Registros de recursos (Resource Records)

| Tipo | Descripción |
|------|-------------|
| `A` | IPv4 de un dominio |
| `AAAA` | IPv6 de un dominio |
| `CNAME` | Alias (ej: `www.google.com` → `google.com`) |
| `SOA` | Servidor primario y datos técnicos de la zona |
| `NS` | Servidor autoritativo de la zona (se replica en caché de otros DNS) |
| `PTR` | Resolución inversa: IP → nombre de dominio |
| `MX` | Servidor de correo |

**Formato de un registro:**
```
www.suarezdefigueroa.es   86400   IN   A   88.2.188.98
[nombre]                  [TTL]  [clase] [tipo] [valor]
```

---

## Herramientas de consulta DNS

```bash
# Windows
ipconfig /all                        # Ver DNS configurado (normalmente el router → 8.8.8.8)
nslookup www.example.com             # IP y servidor DNS que responde
nslookup es.wikipedia.org
nslookup 185.15.58.226               # Resolución inversa

# Ubuntu
nano /etc/resolv.conf                # Ver DNS configurados
ping www.example.com                 # Obtiene IP
host www.example.com                 # Registros A, CNAME, etc.
dig www.example.com                  # Detallado: A, CNAME, TTL, etc.

# Consultar un DNS específico
nslookup ejemplo.com 127.0.0.1
dig @127.0.0.1 prueba.ejemplo.com
```

---

## Instalación de Bind9

```bash
apt update
apt install bind9
```

```bash
systemctl start   bind9
systemctl restart bind9
systemctl status  bind9
systemctl stop    bind9
```

---

## Ficheros de configuración

| Fichero | Función |
|---------|---------|
| `/etc/bind/named.conf` | Principal: incluye los demás |
| `/etc/bind/named.conf.options` | Opciones globales: reenvío, acceso, recursión |
| `/etc/bind/named.conf.local` | Zonas personalizadas |
| `/etc/bind/named.conf.default-zones` | Zona raíz (hint) y localhost |
| `/etc/bind/db.local` | Registros de localhost |
| `/etc/bind/db.127` | Registros PTR de zona inversa de localhost |

---

## named.conf.options

```apache
options {
    # recursion no;                   # Deshabilita consultas recursivas al raíz

    forwarders {
        8.8.8.8;                      # Google DNS
        1.1.1.1;                      # Cloudflare DNS
    };
    # (Solo funciona si recursion está habilitada)

    allow-query     { any; };         # Acepta consultas de cualquier IP (localnet = solo red local)
    allow-transfer  { none; };        # Nadie puede copiar todas las zonas (solo esclavos autorizados)
    allow-recursion { none; };        # Nadie puede hacer búsquedas recursivas

    listen-on port 53 { any; };       # Escucha en todas las interfaces IPv4
    # listen-on-v6 ya escucha en 53 solo en IPv6 por defecto
};
```

---

## Añadir una zona personalizada

### 1. Declarar la zona en named.conf.local

```bash
nano /etc/bind/named.conf.local
```

```apache
zone "ejemplo.com" {
    type master;
    file "/etc/bind/db.ejemplo";
};

zone "0.0.127.in-addr.arpa" {    # Zona inversa para 127.0.0.x
    type master;
    file "/etc/bind/db.127.0.0";
};
```

### 2. Fichero de zona directa

```bash
nano /etc/bind/db.ejemplo
```

```dns
$TTL 86400
@   IN  SOA ns1.ejemplo.com. root.ejemplo.com. (
            1         ; Serial (incrementar al modificar)
            3600      ; Refresh
            1800      ; Retry
            604800    ; Expire
            86400 )   ; Negative Cache TTL
;
@       IN  NS  ns1.ejemplo.com.    ; Servidor autoritativo (el . indica nombre absoluto)
@       IN  A   127.0.0.1           ; IP de ejemplo.com
ns1     IN  A   127.0.0.2           ; IP de ns1.ejemplo.com
prueba  IN  A   127.0.0.3           ; IP de prueba.ejemplo.com
```

### 3. Fichero de zona inversa

```bash
nano /etc/bind/db.127.0.0
```

```dns
$TTL 86400
@   IN  SOA ns1.ejemplo.com. root.ejemplo.com. (
            2         ; Serial
            3600      ; Refresh
            1800      ; Retry
            604800    ; Expire
            86400 )   ; Negative Cache TTL
;
@   IN  NS  ns1.ejemplo.com.
1   PTR ejemplo.com.          ; 127.0.0.1 → ejemplo.com
2   PTR ns1.ejemplo.com.      ; 127.0.0.2 → ns1.ejemplo.com
3   PTR prueba.ejemplo.com.   ; 127.0.0.3 → prueba.ejemplo.com
```

```bash
systemctl restart bind9
```

### 4. Verificar

```bash
nslookup ejemplo.com      127.0.0.1
nslookup ns1.ejemplo.com  127.0.0.1
nslookup prueba.ejemplo.com 127.0.0.1
nslookup 127.0.0.1        127.0.0.1    # Resolución inversa
nslookup 127.0.0.2        127.0.0.1
nslookup 127.0.0.3        127.0.0.1
```

---

## DNS Secundario (esclavo) — simulación en la misma máquina

```bash
# Añadir IPs adicionales a la interfaz loopback
sudo ip addr add 127.0.0.2/8 dev lo
sudo ip addr add 127.0.0.3/8 dev lo
ip a | grep 127                          # Verificar
```

```bash
# Copiar configuración base
sudo systemctl stop bind9
mkdir /etc/bind/slave
cp /etc/bind/named* /etc/bind/slave/
```

**named.conf del maestro** (escucha en 127.0.0.2, puerto 5353):
```apache
options {
    listen-on port 5353 { 127.0.0.2; };
    allow-query   { any; };
    allow-transfer { 127.0.0.3; };       # Permite copia al esclavo
};
```

**named.conf.local del esclavo** (escucha en 127.0.0.3, puerto 5354):
```apache
zone "ejemplo.com" {
    type slave;
    masters { 127.0.0.2; };
    file "/var/cache/bind/db.ejemplo";
};

zone "0.0.127.in-addr.arpa" {
    type slave;
    masters { 127.0.0.2; };
    file "/var/cache/bind/db.127.0.0";
};
```

```bash
# Lanzar ambos en procesos independientes
named -c /etc/bind/named.conf       -f &
named -c /etc/bind/slave/named.conf -f &

# Consultar con puerto específico (nslookup no lo soporta)
dig @127.0.0.2 -p 5353 prueba.ejemplo.com
dig @127.0.0.3 -p 5354 prueba.ejemplo.com

# Matar procesos named
ps aux | grep named
kill -9 <PID>
```

---

## Configurar el DNS por defecto del sistema (Netplan)

```bash
nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp4-overrides:
        use-dns: false          # Mantiene DHCP para la IP pero no para el DNS
      nameservers:
        addresses:
          - 127.0.0.1           # Usar nuestro Bind9 local
  version: 2
```

```bash
netplan apply
```
