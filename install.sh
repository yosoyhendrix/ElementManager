#!/data/data/com.termux/files/usr/bin/bash
# Script para Termux - Instalador de clarox con detección de arquitectura
# Internet Bug Móvil DO - Desarrollador: Near365
# Telegram: @Near365

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# URLs del binario según arquitectura
URL_ARM64="https://raw.githubusercontent.com/IntelectoDev/ElementManager/master/clarox_ARM64"
URL_ARM32="https://raw.githubusercontent.com/IntelectoDev/ElementManager/master/clarox_ARM32"

# Directorio de instalación
DEST="$PREFIX/bin/clarox"
# Cambiar el directorio temporal a uno accesible en Termux
TEMP_FILE="$PREFIX/tmp/clarox_temp"

# Función para mostrar header
show_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║           INSTALADOR CLAROX - TERMUX                 ║${RESET}"
    echo -e "${CYAN}║              Internet Bug Móvil DO                   ║${RESET}"
    echo -e "${CYAN}║           Desarrollador: ${YELLOW}Near365${CYAN}                   ║${RESET}"
    echo -e "${CYAN}║             Telegram: @Near365                       ║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# Función para logging
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[${timestamp}] [INFO] ${message}${RESET}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[${timestamp}] [✓] ${message}${RESET}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[${timestamp}] [⚠] ${message}${RESET}"
            ;;
        "ERROR")
            echo -e "${RED}[${timestamp}] [✗] ${message}${RESET}"
            ;;
    esac
}

# Función para verificar conexión a internet
check_internet() {
    log "INFO" "Verificando conexión a internet..."
    if curl -s --max-time 10 -I https://www.google.com > /dev/null 2>&1; then
        log "SUCCESS" "Conexión a internet verificada"
        return 0
    else
        log "ERROR" "No hay conexión a internet"
        return 1
    fi
}

# Función para verificar si estamos en Termux
check_termux() {
    if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
        log "ERROR" "Este script debe ejecutarse en Termux"
        echo -e "${RED}Por favor instala Termux desde F-Droid o Google Play Store${RESET}"
        exit 1
    fi
    log "SUCCESS" "Entorno Termux verificado"
}

# Función para detectar arquitectura
detect_architecture() {
    ARCH=$(uname -m)
    log "INFO" "Detectando arquitectura del sistema..."
    log "INFO" "Arquitectura detectada: $ARCH"
    
    case "$ARCH" in
        "aarch64"|"arm64")
            log "INFO" "Sistema ARM64 detectado"
            URL="$URL_ARM64"
            ARCH_NAME="ARM64"
            ;;
        "armv7l"|"armv8l"|"armeabi")
            log "INFO" "Sistema ARM32 detectado"
            URL="$URL_ARM32"
            ARCH_NAME="ARM32"
            ;;
        *)
            log "ERROR" "Arquitectura no compatible: $ARCH"
            echo -e "${RED}Arquitecturas soportadas: ARM64, ARM32${RESET}"
            exit 1
            ;;
    esac
}

# Función para actualizar repositorios
update_repositories() {
    log "INFO" "Actualizando repositorios de Termux..."
    if pkg update -y >/dev/null 2>&1; then
        log "SUCCESS" "Repositorios actualizados correctamente"
    else
        log "WARNING" "Error al actualizar repositorios, continuando..."
    fi
}

# Función para instalar dependencias
install_dependencies() {
    log "INFO" "Instalando dependencias necesarias..."
    
    # Lista de paquetes necesarios
    local packages=(
        "python"
        "libffi"
        "python-cryptography"
        "file"
    )
    
    for package in "${packages[@]}"; do
        log "INFO" "Instalando $package..."
        if pkg install -y "$package" >/dev/null 2>&1; then
            log "SUCCESS" "$package instalado correctamente"
        else
            log "WARNING" "Error al instalar $package, continuando..."
        fi
    done
    
    # Instalar dependencias Python específicas
    log "INFO" "Instalando dependencias Python..."
    if pip install --upgrade pip cryptography >/dev/null 2>&1; then
        log "SUCCESS" "Dependencias Python instaladas"
    else
        log "WARNING" "Error al instalar dependencias Python"
    fi
}

# Función para crear directorio temporal
create_temp_dir() {
    log "INFO" "Creando directorio temporal..."
    
    # Crear directorio temporal en $PREFIX/tmp (accesible en Termux)
    local temp_dir="$PREFIX/tmp"
    if mkdir -p "$temp_dir"; then
        log "SUCCESS" "Directorio temporal creado: $temp_dir"
        return 0
    else
        log "ERROR" "Error al crear directorio temporal"
        return 1
    fi
}

# Función para descargar el binario
download_binary() {
    log "INFO" "Descargando clarox ($ARCH_NAME)..."
    log "INFO" "URL: $URL"
    
    # Crear directorio temporal si no existe
    create_temp_dir || return 1
    
    # Descargar con curl con barra de progreso limpia
    if curl -L \
        --retry 3 \
        --retry-delay 2 \
        --max-time 120 \
        --silent \
        --show-error \
        --user-agent "Mozilla/5.0 (Linux; Android 10; Mobile)" \
        -o "$TEMP_FILE" \
        "$URL" \
        --write-out "\n"; then
        
        log "SUCCESS" "Descarga completada"
        return 0
    else
        log "ERROR" "Error al descargar el archivo desde $URL"
        return 1
    fi
}

# Función para verificar el archivo descargado
verify_download() {
    log "INFO" "Verificando archivo descargado..."
    
    if [ ! -f "$TEMP_FILE" ]; then
        log "ERROR" "Archivo temporal no encontrado"
        return 1
    fi
    
    # Verificar que el archivo no está vacío
    if [ ! -s "$TEMP_FILE" ]; then
        log "ERROR" "El archivo descargado está vacío"
        return 1
    fi
    
    # Mostrar información del archivo
    local file_size=$(stat -c%s "$TEMP_FILE" 2>/dev/null || wc -c < "$TEMP_FILE")
    log "INFO" "Tamaño del archivo: $file_size bytes"
    
    # Verificar tipo de archivo si el comando 'file' está disponible
    if command -v file >/dev/null 2>&1; then
        local file_type=$(file "$TEMP_FILE" 2>/dev/null)
        if echo "$file_type" | grep -q "executable\|ELF"; then
            log "SUCCESS" "Archivo verificado como ejecutable válido"
        else
            log "WARNING" "El archivo puede no ser un ejecutable válido, continuando..."
        fi
    else
        # Verificación alternativa: verificar magic numbers ELF
        local magic=$(hexdump -C "$TEMP_FILE" 2>/dev/null | head -n 1 | cut -d' ' -f2-5)
        if echo "$magic" | grep -q "7f 45 4c 46"; then
            log "SUCCESS" "Archivo verificado como ejecutable ELF válido"
        else
            log "WARNING" "No se pudo verificar el tipo de archivo, continuando..."
        fi
    fi
    
    return 0
}

# Función para instalar el binario
install_binary() {
    log "INFO" "Instalando clarox en $DEST..."
    
    # Crear backup si existe versión anterior
    if [ -f "$DEST" ]; then
        log "INFO" "Creando backup de versión anterior..."
        cp "$DEST" "$DEST.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Mover el archivo temporal al destino final
    if mv "$TEMP_FILE" "$DEST"; then
        log "SUCCESS" "Archivo movido correctamente"
    else
        log "ERROR" "Error al mover el archivo a $DEST"
        return 1
    fi
    
    # Hacer ejecutable
    if chmod +x "$DEST"; then
        log "SUCCESS" "Permisos de ejecución aplicados"
    else
        log "ERROR" "Error al aplicar permisos de ejecución"
        return 1
    fi
    
    # Verificar que el binario funciona
    if [ -x "$DEST" ]; then
        log "SUCCESS" "Binario instalado y verificado"
        return 0
    else
        log "ERROR" "El binario no es ejecutable"
        return 1
    fi
}

# Función para crear directorio de configuración
create_config_dir() {
    local config_dir="$HOME/.bugx_config"
    log "INFO" "Creando directorio de configuración..."
    
    if mkdir -p "$config_dir"; then
        chmod 700 "$config_dir"
        log "SUCCESS" "Directorio de configuración creado: $config_dir"
    else
        log "WARNING" "Error al crear directorio de configuración"
    fi
}

# Función para mostrar información post-instalación
show_post_install_info() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║                 INSTALACIÓN COMPLETADA               ║${RESET}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${CYAN}📱 INSTRUCCIONES DE USO:${RESET}"
    echo -e "${WHITE}1. Para ejecutar clarox, escribe: ${GREEN}clarox${RESET}"
    echo -e "${WHITE}2. El programa te mostrará tu HWID único${RESET}"
    echo -e "${WHITE}3. Contacta a un suplidor para activar tu HWID${RESET}"
    echo -e "${WHITE}4. Una vez activado, el programa funcionará automáticamente${RESET}"
    echo ""
    echo -e "${CYAN}🔧 COMANDOS ÚTILES:${RESET}"
    echo -e "${WHITE}• Ejecutar: ${GREEN}clarox${RESET}"
    echo -e "${WHITE}• Detener: ${YELLOW}Ctrl + C${RESET}"
    echo -e "${WHITE}• Reinstalar: ${YELLOW}bash install.sh${RESET}"
    echo ""
    echo -e "${CYAN}📞 SOPORTE:${RESET}"
    echo -e "${WHITE}• Telegram: ${GREEN}@Near365${RESET}"
    echo -e "${WHITE}• Para problemas o activación de HWID${RESET}"
    echo ""
    echo -e "${CYAN}⚠️  NOTAS IMPORTANTES:${RESET}"
    echo -e "${WHITE}• Necesitas conexión a internet para la activación inicial${RESET}"
    echo -e "${WHITE}• El programa mantiene la conexión automáticamente${RESET}"
    echo -e "${WHITE}• Solo funciona en dispositivos móviles con Termux${RESET}"
    echo ""
}

# Función para limpiar archivos temporales
cleanup() {
    log "INFO" "Limpiando archivos temporales..."
    [ -f "$TEMP_FILE" ] && rm -f "$TEMP_FILE"
    log "SUCCESS" "Limpieza completada"
}

# Función principal
main() {
    # Mostrar header
    show_header
    
    # Verificaciones iniciales
    check_termux
    check_internet || {
        log "ERROR" "Se requiere conexión a internet para la instalación"
        exit 1
    }
    
    # Detectar arquitectura
    detect_architecture
    
    # Actualizar repositorios
    update_repositories
    
    # Instalar dependencias
    install_dependencies
    
    # Descargar binario
    download_binary || {
        log "ERROR" "Fallo en la descarga del binario"
        cleanup
        exit 1
    }
    
    # Verificar descarga
    verify_download || {
        log "ERROR" "Fallo en la verificación del archivo"
        cleanup
        exit 1
    }
    
    # Instalar binario
    install_binary || {
        log "ERROR" "Fallo en la instalación del binario"
        cleanup
        exit 1
    }
    
    # Crear directorio de configuración
    create_config_dir
    
    # Limpiar archivos temporales
    cleanup
    
    # Mostrar información post-instalación
    show_post_install_info
    
    log "SUCCESS" "¡Instalación completada exitosamente!"
    
    # Auto-eliminar el script si fue ejecutado directamente
    if [ "$0" = "./install.sh" ] || [ "$0" = "bash install.sh" ]; then
        log "INFO" "Eliminando script de instalación..."
        rm -f "$0" 2>/dev/null || true
    fi
}

# Manejo de señales para limpieza
trap cleanup EXIT INT TERM

# Ejecutar función principal
main "$@"