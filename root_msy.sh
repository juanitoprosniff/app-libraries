#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                            SCRIPT AUTO ROOT SSH                             ║
# ║                                                                              ║
# ║          Script para habilitar acceso root con contraseña en VPS            ║
# ║                     Compatible con Ubuntu 20.04 y 22.04                     ║
# ║                                                                              ║
# ║                          By: JuanitoProSniff                                 ║
# ║                       Telegram: @JuanitoProSniff                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -e  # Salir si hay algún error

# Configuración de colores y estilos
BG_BLUE='\033[44m'      # Fondo azul
CYAN='\033[0;96m'       # Texto cyan
BRIGHT_CYAN='\033[1;96m' # Texto cyan brillante
WHITE='\033[1;97m'      # Texto blanco brillante
RED='\033[1;91m'        # Texto rojo brillante
GREEN='\033[1;92m'      # Texto verde brillante
YELLOW='\033[1;93m'     # Texto amarillo brillante
NC='\033[0m'            # Reset color
BOLD='\033[1m'          # Texto en negrita

# Configuración del marco
FRAME_WIDTH=80
FRAME_CHAR="═"
CORNER_TL="╔"
CORNER_TR="╗"
CORNER_BL="╚"
CORNER_BR="╝"
VERTICAL="║"

# Contraseña por defecto
DEFAULT_PASSWORD="DEAVILA@25"

# Función para crear líneas del marco
create_frame_line() {
    local text="$1"
    local padding=$((FRAME_WIDTH - ${#text} - 4))
    local left_pad=$((padding / 2))
    local right_pad=$((padding - left_pad))
    
    printf "${BG_BLUE}${CYAN}${VERTICAL}%*s${BRIGHT_CYAN}%s${CYAN}%*s${VERTICAL}${NC}\n" \
           $left_pad "" "$text" $right_pad ""
}

# Función para crear línea vacía del marco
create_empty_line() {
    printf "${BG_BLUE}${CYAN}${VERTICAL}%*s${VERTICAL}${NC}\n" $((FRAME_WIDTH - 2)) ""
}

# Función para crear línea de separación
create_separator() {
    printf "${BG_BLUE}${CYAN}${CORNER_TL}"
    for ((i=1; i<FRAME_WIDTH-1; i++)); do
        printf "${FRAME_CHAR}"
    done
    printf "${CORNER_TR}${NC}\n"
}

# Función para crear línea inferior
create_bottom_line() {
    printf "${BG_BLUE}${CYAN}${CORNER_BL}"
    for ((i=1; i<FRAME_WIDTH-1; i++)); do
        printf "${FRAME_CHAR}"
    done
    printf "${CORNER_BR}${NC}\n"
}

# Función para mostrar header con marco
show_header() {
    clear
    echo
    create_separator
    create_empty_line
    create_frame_line "SCRIPT AUTO ROOT SSH"
    create_empty_line
    create_frame_line "Configuracion automatica de acceso root con contraseña"
    create_frame_line "Compatible con Ubuntu 20.04 y 22.04"
    create_empty_line
    create_frame_line "By: JuanitoProSniff"
    create_frame_line "Telegram: @JuanitoProSniff"
    create_empty_line
    create_bottom_line
    echo
}

# Funciones para imprimir mensajes con colores y marco
print_status() {
    printf "${BG_BLUE}${CYAN}${VERTICAL} ${BRIGHT_CYAN}[INFO]${CYAN} %-*s ${VERTICAL}${NC}\n" $((FRAME_WIDTH - 10)) "$1"
}

print_success() {
    printf "${BG_BLUE}${CYAN}${VERTICAL} ${GREEN}[SUCCESS]${CYAN} %-*s ${VERTICAL}${NC}\n" $((FRAME_WIDTH - 13)) "$1"
}

print_warning() {
    printf "${BG_BLUE}${CYAN}${VERTICAL} ${YELLOW}[WARNING]${CYAN} %-*s ${VERTICAL}${NC}\n" $((FRAME_WIDTH - 13)) "$1"
}

print_error() {
    printf "${BG_BLUE}${CYAN}${VERTICAL} ${RED}[ERROR]${CYAN} %-*s ${VERTICAL}${NC}\n" $((FRAME_WIDTH - 11)) "$1"
}

print_input() {
    printf "${BG_BLUE}${CYAN}${VERTICAL} ${WHITE}[INPUT]${CYAN} %-*s ${VERTICAL}${NC}\n" $((FRAME_WIDTH - 11)) "$1"
}

print_frame_text() {
    printf "${BG_BLUE}${CYAN}${VERTICAL} %-*s ${VERTICAL}${NC}\n" $((FRAME_WIDTH - 4)) "$1"
}

# Función para crear marco de sección
start_section() {
    echo
    create_separator
    create_frame_line "$1"
    create_separator
}

# Función para finalizar sección
end_section() {
    create_bottom_line
    echo
}

# Verificar que se ejecuta como root o con sudo
check_permissions() {
    if [ "$EUID" -ne 0 ]; then
        show_header
        start_section "ERROR DE PERMISOS"
        print_error "Este script debe ejecutarse como root o con sudo"
        print_frame_text " "
        print_frame_text "Uso: sudo bash $0"
        end_section
        exit 1
    fi
}

# Detectar versión del sistema
detect_system() {
    start_section "DETECCION DEL SISTEMA"
    
    UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "Desconocida")
    print_status "Detectada Ubuntu $UBUNTU_VERSION"
    
    # CORRECCIÓN: Agregar corchetes para la evaluación de condiciones
    if [ "$UBUNTU_VERSION" != "20.04" ] && [ "$UBUNTU_VERSION" != "22.04" ]; then
        print_warning "Este script esta optimizado para Ubuntu 20.04 y 22.04"
        print_frame_text " "
        print_input "¿Deseas continuar? (y/N): "
        end_section
        
        read -n 1 -r
        echo
        # CORRECCIÓN: Sintaxis correcta para expresiones regulares
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            start_section "OPERACION CANCELADA"
            print_error "Operacion cancelada por el usuario"
            end_section
            exit 1
        fi
    else
        print_success "Sistema compatible detectado"
        end_section
    fi
}

# Backup del archivo SSH original
create_backup() {
    start_section "CREANDO BACKUP DE SEGURIDAD"
    
    SSH_CONFIG="/etc/ssh/sshd_config"
    BACKUP_FILE="/etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)"
    
    print_status "Creando backup de la configuracion SSH..."
    cp "$SSH_CONFIG" "$BACKUP_FILE"
    print_success "Backup creado: $BACKUP_FILE"
    
    end_section
}

# Función para establecer contraseña de root
setup_root_password() {
    start_section "CONFIGURACION DE CONTRASEÑA ROOT"
    
    print_status "Configurando contraseña para el usuario root..."
    print_frame_text " "
    print_frame_text "Contraseña por defecto: $DEFAULT_PASSWORD"
    print_frame_text " "
    
    while true; do
        print_input "Nueva contraseña (ENTER para usar por defecto): "
        printf "${BG_BLUE}${CYAN}${VERTICAL} ${NC}"
        read -s password1
        printf "\n"
        
        # Si está vacío, usar contraseña por defecto
        if [ -z "$password1" ]; then
            password1="$DEFAULT_PASSWORD"
            print_success "Usando contraseña por defecto: $DEFAULT_PASSWORD"
            break
        fi
        
        print_input "Confirma la contraseña: "
        printf "${BG_BLUE}${CYAN}${VERTICAL} ${NC}"
        read -s password2
        printf "\n"
        
        if [ "$password1" = "$password2" ]; then
            if [ ${#password1} -lt 8 ]; then
                print_warning "La contraseña debe tener al menos 8 caracteres"
                continue
            fi
            break
        else
            print_error "Las contraseñas no coinciden. Intenta nuevamente."
        fi
    done
    
    echo "root:$password1" | chpasswd
    print_success "Contraseña de root establecida correctamente"
    
    end_section
}

# Configurar SSH para permitir root login con contraseña
configure_ssh() {
    start_section "CONFIGURANDO ACCESO SSH"
    
    print_status "Configurando SSH para permitir acceso root con contraseña..."
    
    # Crear configuración temporal
    cat > /tmp/ssh_config_temp << 'EOF'
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                     Configuración SSH - AUTO ROOT SCRIPT                    ║
# ║                          By: JuanitoProSniff                                 ║
# ║                       Telegram: @JuanitoProSniff                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Puerto SSH (puedes cambiarlo por seguridad)
Port 22

# Permitir login como root
PermitRootLogin yes

# Habilitar autenticación por contraseña
PasswordAuthentication yes

# Deshabilitar autenticación por clave pública
PubkeyAuthentication no

# Configuraciones de seguridad adicionales
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Configuraciones adicionales de seguridad
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2

# Deshabilitar login de usuarios vacíos
PermitEmptyPasswords no

# Configuración de protocolo
Protocol 2
EOF

    # Aplicar la nueva configuración
    cp /tmp/ssh_config_temp "$SSH_CONFIG"
    rm /tmp/ssh_config_temp
    
    print_success "Configuracion SSH actualizada correctamente"
    
    end_section
}

# Configurar el usuario root
enable_root_account() {
    start_section "HABILITANDO CUENTA ROOT"
    
    print_status "Configurando cuenta root..."
    
    # Asegurar que root tenga un shell válido
    usermod -s /bin/bash root
    print_status "Shell de root configurado: /bin/bash"
    
    # Crear directorio home para root si no existe
    if [ ! -d "/root" ]; then
        mkdir -p /root
        chmod 700 /root
        print_status "Directorio /root creado"
    fi
    
    print_success "Cuenta root habilitada correctamente"
    
    end_section
}

# Actualizar configuración de PAM si es necesario
configure_pam() {
    start_section "VERIFICANDO CONFIGURACION PAM"
    
    print_status "Verificando configuracion PAM para SSH..."
    
    # Asegurar que PAM permita login con contraseña
    if ! grep -q "auth required pam_unix.so" /etc/pam.d/sshd; then
        print_status "Actualizando configuracion PAM..."
        cp /etc/pam.d/sshd /etc/pam.d/sshd.backup
        echo "auth required pam_unix.so" >> /etc/pam.d/sshd
        print_success "Configuracion PAM actualizada"
    else
        print_success "Configuracion PAM correcta"
    fi
    
    end_section
}

# Reiniciar servicio SSH
restart_ssh() {
    start_section "REINICIANDO SERVICIO SSH"
    
    print_status "Verificando configuracion SSH..."
    
    # Verificar configuración antes de reiniciar
    if sshd -t; then
        print_success "Configuracion SSH valida"
        print_status "Reiniciando servicio SSH..."
        systemctl restart ssh
        systemctl enable ssh
        print_success "Servicio SSH reiniciado correctamente"
    else
        print_error "Error en la configuracion SSH"
        print_status "Restaurando backup..."
        cp "$BACKUP_FILE" "$SSH_CONFIG"
        systemctl restart ssh
        print_error "Configuracion restaurada. Revisa los errores."
        end_section
        exit 1
    fi
    
    end_section
}

# Mostrar información final
show_final_info() {
    start_section "CONFIGURACION COMPLETADA"
    
    SERVER_IP=$(curl -s ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')
    
    print_success "¡Configuracion completada exitosamente!"
    print_frame_text " "
    print_frame_text "INFORMACION DE CONEXION:"
    print_frame_text "  • Usuario: root"
    print_frame_text "  • IP del servidor: $SERVER_IP"
    print_frame_text "  • Puerto SSH: 22"
    print_frame_text "  • Autenticacion: Contraseña"
    print_frame_text " "
    print_frame_text "COMANDO DE CONEXION:"
    print_frame_text "  ssh root@$SERVER_IP"
    print_frame_text " "
    print_warning "IMPORTANTE: Prueba la conexion en una nueva terminal"
    print_warning "antes de cerrar esta sesion"
    print_frame_text " "
    print_frame_text "Backup guardado en: $BACKUP_FILE"
    
    end_section
    
    # Footer final
    create_separator
    create_frame_line "SCRIPT AUTO ROOT SSH - COMPLETADO"
    create_empty_line
    create_frame_line "By: JuanitoProSniff"
    create_frame_line "Telegram: @JuanitoProSniff"
    create_empty_line
    create_bottom_line
    echo
}

# Función para mostrar confirmación inicial
show_confirmation() {
    start_section "CONFIRMACION DE EJECUCION"
    
    print_warning "Este script modificara la configuracion SSH de tu servidor"
    print_status "Se creara un backup automatico de la configuracion actual"
    print_frame_text " "
    print_input "¿Deseas continuar? (y/N): "
    
    printf "${BG_BLUE}${CYAN}${VERTICAL} ${NC}"
    read -n 1 -r
    printf "\n"
    
    # CORRECCIÓN: Sintaxis correcta para expresiones regulares
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Operacion cancelada por el usuario"
        end_section
        exit 1
    fi
    
    print_success "Confirmacion recibida. Iniciando proceso..."
    end_section
}

# Función principal
main() {
    # Mostrar header principal
    show_header
    
    # Verificar permisos
    check_permissions
    
    # Mostrar confirmación
    show_confirmation
    
    # Ejecutar pasos de configuración
    detect_system
    create_backup
    setup_root_password
    enable_root_account
    configure_ssh
    configure_pam
    restart_ssh
    show_final_info
}

# Ejecutar función principal
main "$@"