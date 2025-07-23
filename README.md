# Element Manager

<div align="center">
  <a href=""><img src="https://img.shields.io/tokei/lines/github/IntelectoDev/ElementManager?style=for-the-badge" alt="GitHub Lines Code"></a>
  <a href=""><img src="https://img.shields.io/github/forks/IntelectoDev/ElementManager?style=for-the-badge" alt="GitHub forks"></a>
  <a href=""><img src="https://img.shields.io/github/issues/IntelectoDev/ElementManager?style=for-the-badge" alt="GitHub issues"></a>
  <a href=""><img src="https://img.shields.io/github/stars/IntelectoDev/ElementManager?style=for-the-badge" alt="GitHub stars"></a>
  <a href=""><img src="https://img.shields.io/github/license/IntelectoDev/ElementManager?style=for-the-badge" alt="GitHub License"></a>
</div>

## 💻 Requisitos
* Ubuntu 18.04 LTS o superior.
* Debian 9 o superior.

## 🧉 Características
* Administración de usuarios SSH:
  * Agregar (Normal, Token, HWID)
  * Eliminar
  * Editar
  * Crear / Restaurar una copia de seguridad

* Menú de instalación:
  * SSH
  * SSL (Stunnel)
  * Dropbear   
  * OpenVPN
  * Shadowsocks*libev (incluye plug-ins)
  * V2ray / X-UI
  * GetTunel
  * Slowdns
  * BadVPN udpgw (MultiPuertos)
  * Proxys (PYTHON-PUB, PYTHON-SEG, PYTHON-DIR (Proxy de redireccionamiento de puertos), TCP OVER, SQUID)

* Configuración:
  * Administrar Elementary 
  (Encargado de monitorear y notificarte vía Telegram: bloqueo SSH, SSH expirada, reinicio del VPS, protocolos caídos, aviso de inicio de sesión ROOT)
  * Administrar Firewall (UFW):
    * Activar/Desactivar
    * Permitir/Bloquear puertos
  * Cambiar zona horaria (Disponibles solo las de habla hispana)
  * Activar/Desactivar bloqueador de anuncios (Misma lista de hosts que AdAway)
  * Bloquear/Desbloquear P2P (Torrents, etc.)

* Elementary (Monitoreo y Notificación):
  * Usuarios SSH/DROPBEAR/SSL/OPENVPN
  * Tiempo
  * Expiración
  * Monitor de protocolos
  * Notificación de cuenta bloqueada, expirada, reboot, login root

* Desinstalar Element Manager:
  * Elimina todos los archivos/directorios creados por el script
  * Elimina todos los servicios instalados por el script (dropbear, squid, etc.)
  * Restaura el archivo ".bashrc" al estado original
  * Elimina la entrada "/bin/false" del archivo "/etc/shells" (Agregada para el correcto funcionamiento de dropbear)

### **Y mas por venir :)**

## Contacto
**Unicos medios de contactos.**
  * **Telegram: [@Near365](https://t.me/Near365)**
  * **Canal de Telegram: [@ElementManagerScript](https://t.me/ElementManagerScript)**

## 📝 Licencia
[MIT](https://choosealicense.com/licenses/mit/)
