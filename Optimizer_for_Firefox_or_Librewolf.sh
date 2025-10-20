#!/bin/bash

# Script de configuración de Firefox para Linux
# Autor: Yisus

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[38;5;208m'  # Naranja brillante
ORANGE2='\033[38;5;214m' # Naranja claro
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # Sin color

# Banner
mostrar_logo() {
    clear
    echo -e "${ORANGE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${ORANGE2}"
    echo "  ███████╗██╗         ██████╗ ██╗███╗   ██╗ ██████╗ ██████╗ ███╗   ██╗"
    echo "  ██╔════╝██║         ██╔══██╗██║████╗  ██║██╔════╝██╔═══██╗████╗  ██║"
    echo "  █████╗  ██║         ██████╔╝██║██╔██╗ ██║██║     ██║   ██║██╔██╗ ██║"
    echo "  ██╔══╝  ██║         ██╔══██╗██║██║╚██╗██║██║     ██║   ██║██║╚██╗██║"
    echo "  ███████╗███████╗    ██║  ██║██║██║ ╚████║╚██████╗╚██████╔╝██║ ╚████║"
    echo "  ╚══════╝╚══════╝    ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo ""
    echo "  ██████╗ ███████╗██╗         ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗███████╗██████╗  ██████╗ "
    echo "  ██╔══██╗██╔════╝██║         ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝██╔════╝██╔══██╗██╔═══██╗"
    echo "  ██║  ██║█████╗  ██║         ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ █████╗  ██████╔╝██║   ██║"
    echo "  ██║  ██║██╔══╝  ██║         ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ ██╔══╝  ██╔══██╗██║   ██║"
    echo "  ██████╔╝███████╗███████╗    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗███████╗██║  ██║╚██████╔╝"
    echo "  ╚═════╝ ╚══════╝╚══════╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ "
    echo -e "${ORANGE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${WHITE}       Configurador de Parámetros de Firefox/Librewolf${NC}"
    echo -e "${ORANGE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Función para preguntar al usuario
preguntar() {
    local pregunta="$1"
    local respuesta
    echo -e "${YELLOW}${pregunta}${NC}"
    echo -e "${GREEN}Presiona ENTER o ingresa 'y' para continuar, o 'n' para cancelar:${NC} "
    read -r respuesta
    respuesta=$(echo "$respuesta" | tr '[:upper:]' '[:lower:]')
    if [[ -z "$respuesta" || "$respuesta" == "y" || "$respuesta" == "yes" ]]; then
        return 0
    else
        return 1
    fi
}

# Función para encontrar el perfil de Firefox o Librewolf
encontrar_perfil() {
    local tipo="$1"
    local browser_dir
    local browser_name
    
    if [[ "$tipo" == "firefox" ]]; then
        browser_dir="$HOME/.mozilla/firefox"
        browser_name="Firefox"
    else
        browser_dir="$HOME/.librewolf"
        browser_name="Librewolf"
    fi
    
    if [[ ! -d "$browser_dir" ]]; then
        echo -e "${RED}Error: No se encontró el directorio de $browser_name${NC}"
        exit 1
    fi
    
    # Buscar el perfil según el tipo de navegador
    local perfil
    if [[ "$tipo" == "firefox" ]]; then
        # Para Firefox: buscar default-release o default
        perfil=$(find "$browser_dir" -maxdepth 1 -type d -name "*.default-release" | head -n 1)
        if [[ -z "$perfil" ]]; then
            perfil=$(find "$browser_dir" -maxdepth 1 -type d -name "*.default" | head -n 1)
        fi
    else
        # Para Librewolf: buscar default-default
        perfil=$(find "$browser_dir" -maxdepth 1 -type d -name "*.default-default" | head -n 1)
    fi
    
    if [[ -z "$perfil" ]]; then
        echo -e "${RED}Error: No se encontró el perfil de $browser_name${NC}"
        exit 1
    fi
    
    echo "$perfil"
}

# Función para agregar parámetros al user.js
agregar_parametros() {
    local archivo="$1"
    shift
    local parametros=("$@")
    
    for param in "${parametros[@]}"; do
        echo "$param" >> "$archivo"
    done
}

# Función principal
main() {
    mostrar_logo
    
    # Verificar que estamos en Linux
    if [[ "$(uname)" != "Linux" ]]; then
        echo -e "${RED}Este script solo funciona en Linux${NC}"
        exit 1
    fi
    
    # Preguntar qué navegador está usando
    echo -e "${WHITE}¿Qué navegador estás usando?${NC}"
    echo -e "${ORANGE2}Escribe 'F' para Firefox o 'L' para Librewolf:${NC} "
    read -r browser_choice
    browser_choice=$(echo "$browser_choice" | tr '[:lower:]' '[:upper:]')
    
    local BROWSER_TYPE
    local BROWSER_NAME
    
    if [[ "$browser_choice" == "F" ]]; then
        BROWSER_TYPE="firefox"
        BROWSER_NAME="Firefox"
    elif [[ "$browser_choice" == "L" ]]; then
        BROWSER_TYPE="librewolf"
        BROWSER_NAME="Librewolf"
    else
        echo -e "${RED}Opción no válida. Por favor ejecuta el script nuevamente.${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${WHITE}Has seleccionado: ${WHITE}$BROWSER_NAME${NC}"
    echo ""
    
    # Verificar que el navegador está instalado
    if [[ "$BROWSER_TYPE" == "firefox" ]]; then
        if ! command -v firefox &> /dev/null; then
            echo -e "${YELLOW}Advertencia: Firefox no parece estar instalado${NC}"
            read -r continuar
            if [[ "$continuar" != "y" ]]; then
                exit 1
            fi
        fi
    else
        if ! command -v librewolf &> /dev/null; then
            echo -e "${YELLOW}Advertencia: Librewolf no parece estar instalado${NC}"
            read -r continuar
            if [[ "$continuar" != "y" ]]; then
                exit 1
            fi
        fi
    fi
    
    echo -e "${CYAN}Buscando perfil de $BROWSER_NAME...${NC}"
    PERFIL=$(encontrar_perfil "$BROWSER_TYPE")
    USER_JS="$PERFIL/user.js"
    
    echo -e "${GREEN}Perfil encontrado: $PERFIL${NC}"
    echo ""
    
    # Crear backup si existe user.js
    if [[ -f "$USER_JS" ]]; then
        BACKUP="$USER_JS.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$USER_JS" "$BACKUP"
        echo -e "${YELLOW}Backup creado: $BACKUP${NC}"
        echo ""
    fi
    
    # Crear o limpiar user.js
    echo "// Configuración de $BROWSER_NAME - El Rincón del Linuxero" > "$USER_JS"
    echo "// Fecha: $(date)" >> "$USER_JS"
    echo "" >> "$USER_JS"
    
    # 1. Parámetros del compositor
    if preguntar "¿Aplicar cambios a los parámetros del compositor?"; then
        echo ""
        echo -e "${CYAN}Parámetros que serán modificados:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}• toolkit.cosmeticAnimations.enabled = false${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}Aplicando parámetros del compositor...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros del compositor" \
            'user_pref("toolkit.cosmeticAnimations.enabled", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros del compositor aplicados${NC}"
        echo ""
    fi
    
    # 2. Parámetros de GPU
    if preguntar "¿Aplicar cambios a los parámetros de GPU?"; then
        echo ""
        echo -e "${CYAN}Parámetros que serán modificados:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}• dom.webgpu.enabled = true${NC}"
        echo -e "${YELLOW}• gfx.webgpu.ignore-blocklist = true${NC}"
        echo -e "${YELLOW}• gfx.webrender.wait-gpu-finished.disabled = true${NC}"
        echo -e "${YELLOW}• layers.gpu-process.crash-also-crashes-browser = true${NC}"
        echo -e "${YELLOW}• layers.gpu-process.enabled = true${NC}"
        echo -e "${YELLOW}• layers.gpu-process.force-enabled = true${NC}"
        echo -e "${YELLOW}• media.gpu-process-decoder = true${NC}"
        echo -e "${YELLOW}• media.gpu-process-encoder = true${NC}"
        echo -e "${YELLOW}• media.hardware-video-decoding.force-enabled = true${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}Aplicando parámetros de GPU...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de GPU" \
            'user_pref("dom.webgpu.enabled", true);' \
            'user_pref("gfx.webgpu.ignore-blocklist", true);' \
            'user_pref("gfx.webrender.wait-gpu-finished.disabled", true);' \
            'user_pref("layers.gpu-process.crash-also-crashes-browser", true);' \
            'user_pref("layers.gpu-process.enabled", true);' \
            'user_pref("layers.gpu-process.force-enabled", true);' \
            'user_pref("media.gpu-process-decoder", true);' \
            'user_pref("media.gpu-process-encoder", true);' \
            'user_pref("media.hardware-video-decoding.force-enabled", true);' \
            ""
        echo -e "${GREEN}✓ Parámetros de GPU aplicados${NC}"
        echo ""
    fi
    
    # 3. Parámetros de WebRender (WebGL)
    if preguntar "¿Aplicar cambios a los parámetros de WebRender (WebGL)?"; then
        echo ""
        echo -e "${CYAN}Parámetros que serán modificados:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}• layers.acceleration.force-enabled = true${NC}"
        echo -e "${YELLOW}• layers.acceleration.disabled = false${NC}"
        echo -e "${YELLOW}• webgl.force-enabled = true${NC}"
        echo -e "${YELLOW}• gfx.canvas.azure.accelerated = true${NC}"
        echo -e "${YELLOW}• gfx.webrender.all = true${NC}"
        echo -e "${YELLOW}• gfx.webrender.compositor = true${NC}"
        echo -e "${YELLOW}• gfx.webrender.compositor.force-enabled = true${NC}"
        echo -e "${YELLOW}• gfx.webrender.debug.slow-cpu-frame-threshold = 0${NC}"
        echo -e "${YELLOW}• gfx.webrender.layer-compositor = true${NC}"
        echo -e "${YELLOW}• gfx.webrender.wait-gpu-finished.disabled = true${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}Aplicando parámetros de WebRender...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de WebRender (WebGL)" \
            'user_pref("layers.acceleration.force-enabled", true);' \
            'user_pref("layers.acceleration.disabled", false);' \
            'user_pref("webgl.force-enabled", true);' \
            'user_pref("gfx.canvas.azure.accelerated", true);' \
            'user_pref("gfx.webrender.all", true);' \
            'user_pref("gfx.webrender.compositor", true);' \
            'user_pref("gfx.webrender.compositor.force-enabled", true);' \
            'user_pref("gfx.webrender.debug.slow-cpu-frame-threshold", 0);' \
            'user_pref("gfx.webrender.layer-compositor", true);' \
            'user_pref("gfx.webrender.wait-gpu-finished.disabled", true);' \
            ""
        echo -e "${GREEN}✓ Parámetros de WebRender aplicados${NC}"
        echo ""
    fi
    
    # 4. Parámetros de CPU
    if preguntar "¿Aplicar cambios a los parámetros de CPU?"; then
        echo -e "${CYAN}Configurando parámetros de CPU...${NC}"
        echo ""
        echo -e "${YELLOW}Para configurar los parámetros de CPU, necesitas saber el número de hilos de tu procesador.${NC}"
        echo -e "${YELLOW}Ejecuta el siguiente comando en otra terminal:${NC}"
        echo -e "${WHITE}   nproc${NC}"
        echo ""
        echo -e "${GREEN}Ingresa el número de hilos de tu procesador:${NC} "
        read -r num_hilos
        
        # Validar que sea un número
        if [[ ! "$num_hilos" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Error: Debes ingresar un número válido${NC}"
            echo -e "${YELLOW}Saltando parámetros de CPU...${NC}"
        else
            echo ""
            echo -e "${CYAN}Parámetros que serán modificados:${NC}"
            echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}• javascript.options.concurrent_multiprocess_gcs.cpu_divisor = $num_hilos${NC}"
            echo -e "${YELLOW}• dom.ipc.processCount = $num_hilos${NC}"
            echo -e "${YELLOW}• media.ffmpeg.encoder.cpu-used = 0${NC}"
            echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            agregar_parametros "$USER_JS" \
                "// Parámetros de CPU" \
                "user_pref(\"javascript.options.concurrent_multiprocess_gcs.cpu_divisor\", $num_hilos);" \
                "user_pref(\"dom.ipc.processCount\", $num_hilos);" \
                'user_pref("media.ffmpeg.encoder.cpu-used", 0);' \
                ""
            echo -e "${GREEN}✓ Parámetros de CPU aplicados (hilos: $num_hilos)${NC}"
        fi
        echo ""
    fi
    
    # 5. Parámetros de códec de vídeo
    if preguntar "¿Aplicar cambios a los parámetros de códec de vídeo?"; then
        echo ""
        echo -e "${CYAN}Parámetros que serán modificados:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}• media.av1.enabled = false${NC}"
        echo -e "${YELLOW}• media.ffvpx.enabled = false${NC}"
        echo -e "${YELLOW}• media.ffmpeg.vaapi.enabled = true${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}Aplicando parámetros de códec de vídeo...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de códec de vídeo" \
            'user_pref("media.av1.enabled", false);' \
            'user_pref("media.ffvpx.enabled", false);' \
            'user_pref("media.ffmpeg.vaapi.enabled", true);' \
            ""
        echo -e "${GREEN}✓ Parámetros de códec de vídeo aplicados${NC}"
        echo ""
    fi

    # 6. Parámetros de la memoria caché
    if preguntar "¿Aplicar cambios a los parámetros de la memoria caché?"; then
        echo ""
        echo -e "${CYAN}Parámetros que serán modificados:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}• browser.cache.memory.enable = false${NC}"
        echo -e "${YELLOW}• browser.cache.disk.enable = false${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}Aplicando parámetros de códec de vídeo...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de la memoria cache" \
            'user_pref("browser.cache.memory.enable", false);' \
            'user_pref("browser.cache.disk.enable", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros de memoria caché aplicados${NC}"
        echo ""
    fi
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}           ¡Configuración completada con éxito!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Navegador configurado: ${WHITE}$BROWSER_NAME${NC}"
    echo -e "${YELLOW}Archivo de configuración: ${WHITE}$USER_JS${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANTE:${NC}"
    echo -e "${WHITE}• Debes reiniciar $BROWSER_NAME para que los cambios surtan efecto${NC}"
    echo -e "${WHITE}• Puedes verificar los cambios en about:config${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}            Gracias por usar mi script :)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Ejecutar el script
main
