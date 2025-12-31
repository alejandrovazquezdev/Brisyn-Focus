# 🚀 Guía Completa: Desplegar Proyectos en tu Servidor

**Fecha:** 8 de Diciembre de 2025  
**Autor:** GitHub Copilot CLI  
**Para:** Alejandro Vazquez  
**Servidor:** Ubuntu Server (192.168.0.188)  
**Dominio:** vazquezalejandro.digital

---

## 📚 ÍNDICE

1. [Introducción](#introducción)
2. [Requisitos Previos](#requisitos-previos)
3. [Arquitectura del Sistema](#arquitectura-del-sistema)
4. [Proceso Completo Paso a Paso](#proceso-completo-paso-a-paso)
5. [Ejemplos Reales](#ejemplos-reales)
6. [Comandos de Referencia Rápida](#comandos-de-referencia-rápida)
7. [Troubleshooting](#troubleshooting)
8. [Mantenimiento y Actualizaciones](#mantenimiento-y-actualizaciones)

---

## 🎯 INTRODUCCIÓN

Esta guía te enseña cómo desplegar cualquier proyecto web (React, Vue, Svelte, etc.) en tu servidor Ubuntu usando:

- **Cloudflare Tunnel** (bypass de CGNAT)
- **Nginx** (servidor web)
- **Subdominios** para cada proyecto

### ✅ Lo que aprenderás:

- Desplegar proyectos con subdominios personalizados
- Configurar Nginx para múltiples sitios
- Gestionar el túnel de Cloudflare
- Actualizar proyectos existentes

---

## 📋 REQUISITOS PREVIOS

### En tu máquina local (Mac):

- ✅ Proyecto con Vite (o cualquier bundler)
- ✅ Node.js y npm instalados
- ✅ SSH configurado al servidor
- ✅ Terminal/iTerm2

### En el servidor Ubuntu:

- ✅ IP estática configurada (192.168.0.188)
- ✅ Nginx instalado
- ✅ Cloudflare Tunnel activo
- ✅ Usuario con sudo: `alephantom`

### En Cloudflare:

- ✅ Dominio configurado: `vazquezalejandro.digital`
- ✅ Túnel creado: `ubuntu-home`
- ✅ DNS gestionado por Cloudflare

---

## 🏗️ ARQUITECTURA DEL SISTEMA

### Diagrama General

```
┌─────────────────────────────────────────────────────────────────┐
│  TU MÁQUINA (macOS)                                              │
│  /Users/alephantom/Dev/                                          │
│  ├── Portafolio/                                                │
│  ├── TypeInFlow/                                                │
│  └── blog-tutorial-CGNATBYPASS/                                 │
│                                                                  │
│  $ npm run build → dist/                                        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                    (SSH + SCP)
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  SERVIDOR UBUNTU (192.168.0.188)                                │
│  /var/www/                                                      │
│  ├── portfolio/          ← vazquezalejandro.digital            │
│  ├── typeinflow/         ← typeinflow.vazquezalejandro.digital │
│  └── blog-cgnattunel/    ← blog-cgnattunel.vazquezalejandro... │
│                                                                  │
│  Nginx (puerto 80) ← Cloudflare Tunnel                         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                  (Cloudflare Tunnel)
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  CLOUDFLARE EDGE NETWORK                                        │
│  ├── DNS: vazquezalejandro.digital                             │
│  ├── SSL/TLS: HTTPS automático                                 │
│  ├── CDN: Cache global                                          │
│  └── DDoS Protection                                            │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                      (Internet)
                            ↓
                    👤 USUARIOS
```

---

## 🚀 PROCESO COMPLETO PASO A PASO

### PASO 1: Preparar el Proyecto Local

#### 1.1. Verificar que el proyecto esté listo

```bash
cd /Users/alephantom/Dev/TuProyecto
```

#### 1.2. Verificar scripts de build

```bash
cat package.json | grep -A 3 "scripts"
```

**Debe tener algo como:**
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build"  // ← Este es el importante
  }
}
```

---

### PASO 2: Build del Proyecto

#### 2.1. Ejecutar el build

```bash
cd /Users/alephantom/Dev/TuProyecto
npm run build
```

**Output esperado:**
```
vite v7.x.x building for production...
✓ X modules transformed.
dist/index.html        X.XX kB
dist/assets/index.js   XXX kB
✓ built in Xs
```

#### 2.2. Verificar que se generó `dist/`

```bash
ls -la dist/
```

**Deberías ver:**
```
dist/
├── index.html
├── assets/
│   ├── index-XXXXX.js
│   └── index-XXXXX.css
└── [archivos estáticos]
```

---

### PASO 3: Decidir el Nombre del Subdominio

**Formato recomendado:**

```
nombre-proyecto.vazquezalejandro.digital
```

**Ejemplos:**
- `blog.vazquezalejandro.digital`
- `typeinflow.vazquezalejandro.digital`
- `portfolio.vazquezalejandro.digital`
- `api.vazquezalejandro.digital`

**Importante:** 
- Usa minúsculas
- Usa guiones (-) en vez de espacios
- Manténlo corto y descriptivo

---

### PASO 4: Comprimir y Transferir

#### 4.1. Comprimir el build

```bash
cd /Users/alephantom/Dev/TuProyecto
tar --no-xattrs -czf proyecto.tar.gz dist/
```

**Nota:** `--no-xattrs` evita warnings de macOS en Linux.

#### 4.2. Verificar el tamaño

```bash
ls -lh proyecto.tar.gz
```

#### 4.3. Transferir al servidor

```bash
scp proyecto.tar.gz alephantom@192.168.0.188:/tmp/
```

**Output esperado:**
```
proyecto.tar.gz    100%  XXX KB   X.XMB/s   00:00
```

---

### PASO 5: Desplegar en el Servidor

#### 5.1. Conectar al servidor

```bash
ssh alephantom@192.168.0.188
```

#### 5.2. Extraer el archivo

```bash
cd /tmp
tar -xzf proyecto.tar.gz
ls -la dist/
```

**Nota:** Ignora warnings de `LIBARCHIVE.xattr`, son normales.

#### 5.3. Crear directorio para el proyecto

```bash
echo "1010234" | sudo -S mkdir -p /var/www/nombre-proyecto
```

**Reemplaza `nombre-proyecto` con el nombre de tu subdominio.**

#### 5.4. Copiar archivos

```bash
echo "1010234" | sudo -S rm -rf /var/www/nombre-proyecto/*
echo "1010234" | sudo -S cp -r dist/* /var/www/nombre-proyecto/
```

#### 5.5. Configurar permisos

```bash
echo "1010234" | sudo -S chown -R www-data:www-data /var/www/nombre-proyecto/
```

#### 5.6. Verificar

```bash
ls -lh /var/www/nombre-proyecto/
```

**Deberías ver:**
```
total XXK
drwxr-xr-x 2 www-data www-data 4.0K ... assets
-rw-r--r-- 1 www-data www-data  XXX ... index.html
-rw-r--r-- 1 www-data www-data  XXX ... [otros archivos]
```

---

### PASO 6: Configurar Nginx

#### 6.1. Crear archivo de configuración

En tu **máquina local**, crea el archivo:

```bash
cat > /tmp/nginx-nombre-proyecto.conf << 'EOF'
server {
    listen 80;
    server_name nombre-proyecto.vazquezalejandro.digital;
    
    root /var/www/nombre-proyecto;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Logs específicos
    access_log /var/log/nginx/nombre-proyecto_access.log;
    error_log /var/log/nginx/nombre-proyecto_error.log;
}
EOF
```

**Reemplaza `nombre-proyecto` en 3 lugares:**
- `server_name`
- `root`
- `access_log` y `error_log`

#### 6.2. Transferir configuración

```bash
scp /tmp/nginx-nombre-proyecto.conf alephantom@192.168.0.188:/tmp/
```

#### 6.3. Activar en el servidor

```bash
ssh alephantom@192.168.0.188
echo "1010234" | sudo -S cp /tmp/nginx-nombre-proyecto.conf /etc/nginx/sites-available/nombre-proyecto
echo "1010234" | sudo -S ln -sf /etc/nginx/sites-available/nombre-proyecto /etc/nginx/sites-enabled/nombre-proyecto
```

#### 6.4. Verificar sintaxis de Nginx

```bash
echo "1010234" | sudo -S nginx -t
```

**Output esperado:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

#### 6.5. Recargar Nginx

```bash
echo "1010234" | sudo -S systemctl reload nginx
```

---

### PASO 7: Actualizar Cloudflare Tunnel

#### 7.1. Ver configuración actual

```bash
ssh alephantom@192.168.0.188
cat /etc/cloudflared/config.yml
```

#### 7.2. Crear nueva configuración

En tu **máquina local**:

```bash
cat > /tmp/cloudflared-config.yml << 'EOF'
tunnel: c48e5781-7e09-4a63-a567-e1fc1a87e11d

ingress:
  - hostname: vazquezalejandro.digital
    service: http://localhost:80
  - hostname: www.vazquezalejandro.digital
    service: http://localhost:80
  - hostname: typeinflow.vazquezalejandro.digital
    service: http://localhost:80
  - hostname: blog-cgnattunel.vazquezalejandro.digital
    service: http://localhost:80
  - hostname: nombre-proyecto.vazquezalejandro.digital
    service: http://localhost:80
  - service: http_status:404
EOF
```

**Agrega tu nuevo hostname antes de la línea `- service: http_status:404`**

#### 7.3. Transferir y aplicar

```bash
scp /tmp/cloudflared-config.yml alephantom@192.168.0.188:/tmp/

ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S cp /tmp/cloudflared-config.yml /etc/cloudflared/config.yml && sudo -S systemctl restart cloudflared'
```

#### 7.4. Verificar estado

```bash
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S systemctl status cloudflared | head -15'
```

**Busca:** `active (running)` y `Registered tunnel connection` (debe haber 4).

---

### PASO 8: Configurar DNS en Cloudflare

#### 8.1. Ir al dashboard

1. **URL:** https://dash.cloudflare.com
2. **Selecciona:** `vazquezalejandro.digital`
3. **Ve a:** DNS → Records

#### 8.2. Agregar registro CNAME

**Configuración:**
```
Type: CNAME
Name: nombre-proyecto
Target: c48e5781-7e09-4a63-a567-e1fc1a87e11d.cfargotunnel.com
Proxy status: Proxied (🟠 naranja - activado)
TTL: Auto
```

#### 8.3. Guardar

Click en **"Save"**

**Espera 1-2 minutos** para que el DNS se propague.

---

### PASO 9: Verificar que Funciona

#### 9.1. Test desde terminal

```bash
curl -I https://nombre-proyecto.vazquezalejandro.digital
```

**Output esperado:**
```
HTTP/2 200
content-type: text/html
server: cloudflare
```

#### 9.2. Test desde navegador

Abre: `https://nombre-proyecto.vazquezalejandro.digital`

**Si no ves cambios:**
- **Hard refresh:** `Cmd + Shift + R` (Mac) o `Ctrl + Shift + R` (Windows)
- Espera 2-3 minutos más

---

## 📦 EJEMPLOS REALES

### Ejemplo 1: Portafolio Principal

```bash
# 1. Build
cd /Users/alephantom/Dev/Portafolio
npm run build

# 2. Comprimir y transferir
tar --no-xattrs -czf portfolio.tar.gz dist/
scp portfolio.tar.gz alephantom@192.168.0.188:/tmp/

# 3. Desplegar
ssh alephantom@192.168.0.188
cd /tmp
tar -xzf portfolio.tar.gz
echo "1010234" | sudo -S mkdir -p /var/www/portfolio
echo "1010234" | sudo -S rm -rf /var/www/portfolio/*
echo "1010234" | sudo -S cp -r dist/* /var/www/portfolio/
echo "1010234" | sudo -S chown -R www-data:www-data /var/www/portfolio/

# 4-9. Continúa con Nginx, Tunnel y DNS...
```

**URL final:** https://vazquezalejandro.digital

---

### Ejemplo 2: TypeInFlow

```bash
# 1. Build
cd /Users/alephantom/Dev/TypeInFlow
npm run build

# 2. Comprimir y transferir
tar --no-xattrs -czf typeinflow.tar.gz dist/
scp typeinflow.tar.gz alephantom@192.168.0.188:/tmp/

# 3. Desplegar
ssh alephantom@192.168.0.188
cd /tmp
tar -xzf typeinflow.tar.gz
echo "1010234" | sudo -S mkdir -p /var/www/typeinflow
echo "1010234" | sudo -S rm -rf /var/www/typeinflow/*
echo "1010234" | sudo -S cp -r dist/* /var/www/typeinflow/
echo "1010234" | sudo -S chown -R www-data:www-data /var/www/typeinflow/

# Nginx config
cat > /tmp/nginx-typeinflow.conf << 'EOF'
server {
    listen 80;
    server_name typeinflow.vazquezalejandro.digital;
    root /var/www/typeinflow;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

scp /tmp/nginx-typeinflow.conf alephantom@192.168.0.188:/tmp/
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S cp /tmp/nginx-typeinflow.conf /etc/nginx/sites-available/typeinflow && sudo -S ln -sf /etc/nginx/sites-available/typeinflow /etc/nginx/sites-enabled/typeinflow && sudo -S nginx -t && sudo -S systemctl reload nginx'

# DNS: Agregar CNAME "typeinflow" en Cloudflare
```

**URL final:** https://typeinflow.vazquezalejandro.digital

---

### Ejemplo 3: Blog CGNAT Tunnel

```bash
# 1. Build
cd /Users/alephantom/Dev/blog-tutorial-CGNATBYPASS
npm run build

# 2. Comprimir y transferir
tar --no-xattrs -czf blog.tar.gz dist/
scp blog.tar.gz alephantom@192.168.0.188:/tmp/

# 3. Desplegar
ssh alephantom@192.168.0.188
cd /tmp
tar -xzf blog.tar.gz
echo "1010234" | sudo -S mkdir -p /var/www/blog-cgnattunel
echo "1010234" | sudo -S rm -rf /var/www/blog-cgnattunel/*
echo "1010234" | sudo -S cp -r dist/* /var/www/blog-cgnattunel/
echo "1010234" | sudo -S chown -R www-data:www-data /var/www/blog-cgnattunel/

# 4-9. Nginx + Tunnel + DNS...
```

**URL final:** https://blog-cgnattunel.vazquezalejandro.digital

---

## ⚡ COMANDOS DE REFERENCIA RÁPIDA

### Build y Deploy Rápido

```bash
# Variables
PROJECT_NAME="nombre-proyecto"
PROJECT_PATH="/Users/alephantom/Dev/NombreProyecto"
SUBDOMAIN="nombre-proyecto"
SERVER="alephantom@192.168.0.188"
PASSWORD="1010234"

# One-liner completo
cd $PROJECT_PATH && \
npm run build && \
tar --no-xattrs -czf deploy.tar.gz dist/ && \
scp deploy.tar.gz $SERVER:/tmp/ && \
ssh $SERVER "cd /tmp && tar -xzf deploy.tar.gz && echo '$PASSWORD' | sudo -S mkdir -p /var/www/$PROJECT_NAME && sudo -S rm -rf /var/www/$PROJECT_NAME/* && sudo -S cp -r dist/* /var/www/$PROJECT_NAME/ && sudo -S chown -R www-data:www-data /var/www/$PROJECT_NAME/ && ls -lh /var/www/$PROJECT_NAME/"
```

---

### Actualizar Proyecto Existente

Si el proyecto ya está configurado (Nginx + Tunnel + DNS):

```bash
# Desde el directorio del proyecto
npm run build
tar --no-xattrs -czf deploy.tar.gz dist/
scp deploy.tar.gz alephantom@192.168.0.188:/tmp/
ssh alephantom@192.168.0.188 'cd /tmp && tar -xzf deploy.tar.gz && echo "1010234" | sudo -S rm -rf /var/www/NOMBRE/* && sudo -S cp -r dist/* /var/www/NOMBRE/ && sudo -S chown -R www-data:www-data /var/www/NOMBRE/'
```

**Reemplaza `NOMBRE` con el nombre de tu proyecto.**

---

### Verificar Estado del Sistema

```bash
# Estado de Nginx
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S systemctl status nginx'

# Estado de Cloudflare Tunnel
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S systemctl status cloudflared'

# Listar todos los sitios activos
ssh alephantom@192.168.0.188 'ls -la /var/www/'

# Ver configuraciones de Nginx
ssh alephantom@192.168.0.188 'ls -la /etc/nginx/sites-enabled/'

# Ver logs de Nginx
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tail -f /var/log/nginx/NOMBRE_access.log'
```

---

### Test de Conectividad

```bash
# Test HTTP status
curl -I https://tu-proyecto.vazquezalejandro.digital

# Test completo con HTML
curl -s https://tu-proyecto.vazquezalejandro.digital | head -20

# Test de DNS
nslookup tu-proyecto.vazquezalejandro.digital

# Test de SSL
openssl s_client -connect tu-proyecto.vazquezalejandro.digital:443 -servername tu-proyecto.vazquezalejandro.digital
```

---

## 🔧 TROUBLESHOOTING

### Problema 1: Error 502 Bad Gateway

**Síntomas:**
```
HTTP/2 502
```

**Causas comunes:**
- Nginx no está corriendo
- Cloudflare Tunnel no está conectado
- Configuración incorrecta

**Solución:**
```bash
# 1. Verificar Nginx
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S systemctl status nginx'

# 2. Verificar Cloudflare Tunnel
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S systemctl status cloudflared'

# 3. Reiniciar ambos
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S systemctl restart nginx && sudo -S systemctl restart cloudflared'
```

---

### Problema 2: Error 404 Not Found

**Síntomas:**
```
HTTP/2 404
```

**Causas comunes:**
- Archivos no copiados correctamente
- Permisos incorrectos
- Ruta incorrecta en Nginx

**Solución:**
```bash
# 1. Verificar archivos
ssh alephantom@192.168.0.188 'ls -la /var/www/nombre-proyecto/'

# 2. Verificar permisos
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S chown -R www-data:www-data /var/www/nombre-proyecto/'

# 3. Ver logs de Nginx
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tail -50 /var/log/nginx/nombre-proyecto_error.log'
```

---

### Problema 3: DNS no resuelve

**Síntomas:**
```bash
curl: (6) Could not resolve host: tu-proyecto.vazquezalejandro.digital
```

**Causas comunes:**
- DNS no agregado en Cloudflare
- DNS mal configurado
- Propagación DNS pendiente

**Solución:**
```bash
# 1. Verificar DNS
nslookup tu-proyecto.vazquezalejandro.digital

# 2. Test directo al túnel
curl -I https://c48e5781-7e09-4a63-a567-e1fc1a87e11d.cfargotunnel.com -H "Host: tu-proyecto.vazquezalejandro.digital"

# 3. Esperar propagación (2-5 minutos)
# 4. Verificar en Cloudflare dashboard
```

---

### Problema 4: Archivos no se actualizan en el navegador

**Síntomas:**
- Ves la versión vieja del sitio
- Cambios no aparecen

**Causas comunes:**
- Cache del navegador
- Cache de Cloudflare

**Solución:**
```bash
# 1. Hard refresh en el navegador
# Mac: Cmd + Shift + R
# Windows/Linux: Ctrl + Shift + R

# 2. Verificar que los archivos se actualizaron
ssh alephantom@192.168.0.188 'ls -lht /var/www/nombre-proyecto/ | head -10'

# 3. Limpiar cache de Cloudflare (en dashboard)
# Cloudflare → Caching → Purge Everything

# 4. Verificar hashes de archivos
curl -s https://tu-proyecto.vazquezalejandro.digital | grep "assets"
```

---

### Problema 5: SPA routing no funciona (404 en rutas)

**Síntomas:**
- Home page funciona (`/`)
- Otras rutas dan 404 (`/about`, `/contact`)

**Causa:**
- Falta configuración `try_files` en Nginx

**Solución:**

Verificar que tu configuración de Nginx tenga:

```nginx
location / {
    try_files $uri $uri/ /index.html;  # ← Esta línea es crucial
}
```

Si falta, editar y recargar:
```bash
ssh alephantom@192.168.0.188
echo "1010234" | sudo -S nano /etc/nginx/sites-available/nombre-proyecto
# Agregar la línea try_files
echo "1010234" | sudo -S nginx -t
echo "1010234" | sudo -S systemctl reload nginx
```

---

## 🔄 MANTENIMIENTO Y ACTUALIZACIONES

### Actualizar un Proyecto Existente

**Proceso simplificado:**

```bash
# 1. Hacer cambios en tu código local
cd /Users/alephantom/Dev/TuProyecto
# ... editas archivos ...

# 2. Build
npm run build

# 3. Desplegar (usa el one-liner)
tar --no-xattrs -czf deploy.tar.gz dist/
scp deploy.tar.gz alephantom@192.168.0.188:/tmp/
ssh alephantom@192.168.0.188 'cd /tmp && tar -xzf deploy.tar.gz && echo "1010234" | sudo -S rm -rf /var/www/NOMBRE/* && sudo -S cp -r dist/* /var/www/NOMBRE/ && sudo -S chown -R www-data:www-data /var/www/NOMBRE/'

# 4. Verificar
curl -I https://tu-proyecto.vazquezalejandro.digital
```

---

### Monitoreo de Logs

```bash
# Ver logs de acceso en tiempo real
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tail -f /var/log/nginx/nombre-proyecto_access.log'

# Ver logs de error
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tail -f /var/log/nginx/nombre-proyecto_error.log'

# Ver logs de Cloudflare Tunnel
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S journalctl -u cloudflared -f'

# Ver últimas 50 líneas de cualquier log
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tail -50 /var/log/nginx/nombre-proyecto_access.log'
```

---

### Eliminar un Proyecto

**Si quieres quitar un proyecto del servidor:**

```bash
# 1. Remover archivos
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S rm -rf /var/www/nombre-proyecto/'

# 2. Desactivar Nginx
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S rm /etc/nginx/sites-enabled/nombre-proyecto && sudo -S systemctl reload nginx'

# 3. Remover de Cloudflare Tunnel config
# Edita /etc/cloudflared/config.yml y quita la línea del hostname

# 4. Remover DNS de Cloudflare dashboard
# Dashboard → DNS → Eliminar el registro CNAME
```

---

### Backup de Proyectos

**Hacer backup periódico:**

```bash
# Backup de todos los sitios
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tar -czf /tmp/backup-sitios-$(date +%Y%m%d).tar.gz /var/www/* && sudo -S chown alephantom:alephantom /tmp/backup-sitios-*.tar.gz'

# Descargar backup
scp alephantom@192.168.0.188:/tmp/backup-sitios-*.tar.gz ~/Backups/

# Backup de configuraciones
ssh alephantom@192.168.0.188 'echo "1010234" | sudo -S tar -czf /tmp/backup-configs-$(date +%Y%m%d).tar.gz /etc/nginx/sites-available/ /etc/cloudflared/config.yml'
scp alephantom@192.168.0.188:/tmp/backup-configs-*.tar.gz ~/Backups/
```

---

## 📊 RESUMEN DE ESTRUCTURA FINAL

### Archivos en el Servidor

```
/var/www/
├── portfolio/                    # Sitio 1
│   ├── index.html
│   ├── assets/
│   └── ...
├── typeinflow/                   # Sitio 2
│   ├── index.html
│   ├── assets/
│   └── ...
└── blog-cgnattunel/             # Sitio 3
    ├── index.html
    ├── assets/
    └── ...

/etc/nginx/sites-available/
├── portfolio
├── typeinflow
└── blog-cgnattunel

/etc/nginx/sites-enabled/
├── portfolio        → ../sites-available/portfolio
├── typeinflow       → ../sites-available/typeinflow
└── blog-cgnattunel  → ../sites-available/blog-cgnattunel

/etc/cloudflared/
└── config.yml       # Configuración del túnel
```

---

### URLs Activas

```
1. https://vazquezalejandro.digital
   https://www.vazquezalejandro.digital

2. https://typeinflow.vazquezalejandro.digital

3. https://blog-cgnattunel.vazquezalejandro.digital

[Tus futuros proyectos aquí]
```

---

## 🎯 CHECKLIST DE DEPLOY

Usa esto cada vez que despliegues un proyecto nuevo:

```
□ Build del proyecto local (npm run build)
□ Verificar que dist/ existe
□ Decidir nombre del subdominio
□ Comprimir build (tar --no-xattrs -czf)
□ Transferir al servidor (scp)
□ Conectar al servidor (ssh)
□ Extraer archivos (tar -xzf)
□ Crear directorio en /var/www/
□ Copiar archivos a /var/www/nombre/
□ Configurar permisos (chown www-data:www-data)
□ Crear configuración de Nginx
□ Transferir config de Nginx
□ Activar sitio en sites-enabled
□ Test de Nginx (nginx -t)
□ Recargar Nginx (systemctl reload)
□ Actualizar /etc/cloudflared/config.yml
□ Reiniciar cloudflared
□ Verificar 4 conexiones activas
□ Agregar DNS CNAME en Cloudflare
□ Activar Proxy (🟠 naranja)
□ Esperar 2-3 minutos
□ Test con curl
□ Test en navegador
□ Hard refresh si es necesario
□ ✅ ¡Deploy completado!
```

---

## 🚀 PRÓXIMOS PASOS

### Mejoras Futuras (Opcional)

1. **Automatización con GitHub Actions**
   - Deploy automático al hacer push
   - CI/CD pipeline completo

2. **Monitoreo**
   - UptimeRobot para alertas
   - Grafana para métricas
   - Logs centralizados

3. **Seguridad**
   - Rate limiting en Nginx
   - Fail2ban para SSH
   - Firewall UFW

4. **Performance**
   - Cache de Cloudflare optimizado
   - Compresión gzip/brotli
   - Lazy loading de imágenes

---

## 📚 RECURSOS ADICIONALES

### Documentación

- **Nginx:** https://nginx.org/en/docs/
- **Cloudflare Tunnel:** https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **Vite:** https://vitejs.dev/guide/

### Archivos de Referencia

```
/Users/alephantom/
├── SESION_COMPLETA_CLOUDFLARE_TUNNEL_Y_DEPLOYMENT.md
├── TUTORIAL_CLOUDFLARE_TUNNEL_COMPLETO.md
├── COMO_FUNCIONA_UN_SERVIDOR_WEB_Y_REACT.md
└── GUIA_DEPLOY_PROYECTOS_AL_SERVIDOR.md  ← Este archivo
```

---

## ✅ CONCLUSIÓN

Ya dominas el proceso completo de deployment:

1. ✅ Build con Vite
2. ✅ Transferencia SSH/SCP
3. ✅ Configuración de Nginx
4. ✅ Gestión de Cloudflare Tunnel
5. ✅ DNS en Cloudflare
6. ✅ Troubleshooting común

**Cada proyecto nuevo toma ~10-15 minutos** cuando ya conoces el proceso.

---

**¡Éxito con tus deployments!** 🎉

---

**Generado por:** GitHub Copilot CLI  
**Fecha:** 8 de Diciembre de 2025  
**Versión:** 1.0  
**Para:** Alejandro Vazquez  
**Servidor:** Ubuntu + Nginx + Cloudflare Tunnel
