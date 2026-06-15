# 10 · Túnel Cloudflare

Permite exponer un servidor local en Internet **sin abrir puertos en el router**, creando un túnel cifrado hacia la red de Cloudflare.

---

## Instalación de cloudflared

```bash
# Añadir clave GPG de Cloudflare
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
    | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Añadir repositorio
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] \
    https://pkg.cloudflare.com/cloudflared jammy main' \
    | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Instalar
sudo apt-get update && sudo apt-get install cloudflared
```

---

## Configuración

Los ficheros de configuración se almacenan en `~/.cloudflared/`.

```bash
mkdir -p ~/.cloudflared

# Obtener config.yml desde el servidor del profesor (adaptador puente)
cd ~/.cloudflared
curl -o config.yml 192.168.56.1:80/config.yml
```

---

## Arrancar el túnel

Se recomienda lanzarlo en una sesión `screen` para que siga corriendo al cerrar la terminal:

```bash
screen
cloudflared tunnel --config ~/.cloudflared/config.yml run .
# Ctrl+a d  → detach (deja corriendo en segundo plano)
```

El subdominio asignado sigue el patrón:
```
alumnoX.iesvalledeljerteplasencia.com
```

---

## Panel de administración

- **Zero Trust Dashboard:** https://one.dash.cloudflare.com/
- Usuario: `t************m`
- Contraseña: `I************p`

> Si aparece el error **1033**, acceder al panel de Zero Trust para que se reactive el conector.
> Ruta directa: https://one.dash.cloudflare.com/62da8e52671c3b073d49fc0e6bcb8c24/networks/connectors

---

## Referencia adicional

Guía completa con capturas: [Google Docs — Túnel Cloudflare](https://docs.google.com/document/d/1hTmdaT51Fv8hbmwzb-x_6IOqROhZgC-k/edit)
