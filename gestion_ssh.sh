#!/bin/bash

SERVICIO="ssh"

if [ "$EUID" -ne 0 ]; then
    echo "Ejecuta este script con sudo."
    exit 1
fi

mostrar_info_inicial() {
    echo "      GESTOR DEL SERVICIO SSH"
    echo
    echo "IP del equipo:"
    hostname -I
    echo
    echo "Estado del servicio SSH:"
    systemctl is-active "$SERVICIO"
    echo
}

pausa() {
    read -rp "Pulsa Enter para continuar..."
}

instalar_ssh_comandos() {
    echo "Instalando SSH..."
    apt update
    apt install -y openssh-server
    systemctl enable --now ssh
    echo
    echo "SSH instalado correctamente."
}

instalar_ssh_ansible() {
    echo "Opción Ansible todavía no implementada."
}

instalar_ssh_docker() {
    echo "Opción Docker todavía no implementada."
}

eliminar_ssh() {
    echo "Eliminando SSH..."
    systemctl stop ssh 2>/dev/null
    apt remove --purge -y openssh-server
    apt autoremove -y
    echo
    echo "SSH eliminado."
}

iniciar_ssh() {
    systemctl start ssh
    echo
    echo "SSH iniciado."
}

parar_ssh() {
    systemctl stop ssh
    echo
    echo "SSH detenido."
}

reiniciar_ssh() {
    systemctl restart ssh
    echo
    echo "SSH reiniciado."
}

ver_estado_ssh() {
    systemctl status ssh --no-pager
}

ver_logs_recientes() {
    echo
    echo "Últimos 20 logs del servicio SSH:"
    journalctl -u ssh -n 20 --no-pager
}

ver_logs_por_fecha() {
    echo
    read -rp "Introduce la fecha (YYYY-MM-DD): " fecha
    journalctl -u ssh --since "$fecha 00:00:00" --until "$fecha 23:59:59" --no-pager
}

cambiar_puerto() {
    echo
    read -rp "Nuevo puerto SSH: " puerto

    if [[ ! "$puerto" =~ ^[0-9]+$ ]] || [ "$puerto" -lt 1 ] || [ "$puerto" -gt 65535 ]; then
        echo "Puerto no válido."
        return
    fi

    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    if grep -qE '^[# ]*Port ' /etc/ssh/sshd_config; then
        sed -i "s/^[# ]*Port .*/Port $puerto/" /etc/ssh/sshd_config
    else
        echo "Port $puerto" >> /etc/ssh/sshd_config
    fi

    systemctl restart ssh
    echo
    echo "Puerto SSH cambiado a $puerto"
}




# ==========================
# PARAMETROS POR CONSOLA
# ==========================

if [ $# -gt 0 ]; then

    case "$1" in

        instalar)
            instalar_ssh_comandos
            exit 0
            ;;

        eliminar)
            eliminar_ssh
            exit 0
            ;;

        iniciar)
            iniciar_ssh
            exit 0
            ;;

        parar)
            parar_ssh
            exit 0
            ;;

        reiniciar)
            reiniciar_ssh
            exit 0
            ;;

        estado)
            ver_estado_ssh
            exit 0
            ;;

        logs)
            ver_logs_recientes
            exit 0
            ;;

        *)
            echo "Parametro no valido."
            echo
            echo "Uso:"
            echo "./gestion_ssh.sh instalar"
            echo "./gestion_ssh.sh eliminar"
            echo "./gestion_ssh.sh iniciar"
            echo "./gestion_ssh.sh parar"
            echo "./gestion_ssh.sh reiniciar"
            echo "./gestion_ssh.sh estado"
            echo "./gestion_ssh.sh logs"
            exit 1
            ;;
    esac

fi

menu() {
    clear

    mostrar_info_inicial

    echo "1) Instalar SSH con comandos"
    echo "2) Instalar SSH con Ansible"
    echo "3) Instalar SSH con Docker"
    echo "4) Eliminar SSH"
    echo "5) Iniciar SSH"
    echo "6) Parar SSH"
    echo "7) Reiniciar SSH"
    echo "8) Ver estado SSH"
    echo "9) Ver logs recientes"
    echo "10) Ver logs por fecha"
    echo "11) Cambiar puerto SSH"
    echo "0) Salir"
    echo

    read -rp "Selecciona una opción: " opcion
}

while true
do
    menu

    case $opcion in
        1)
            instalar_ssh_comandos
            pausa
            ;;
        2)
            instalar_ssh_ansible
            pausa
            ;;
        3)
            instalar_ssh_docker
            pausa
            ;;
        4)
            eliminar_ssh
            pausa
            ;;
        5)
            iniciar_ssh
            pausa
            ;;
        6)
            parar_ssh
            pausa
            ;;
        7)
            reiniciar_ssh
            pausa
            ;;
        8)
            ver_estado_ssh
            pausa
            ;;
        9)
            ver_logs_recientes
            pausa
            ;;
        10)
            ver_logs_por_fecha
            pausa
            ;;
        11)
            cambiar_puerto
            pausa
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            pausa
            ;;
    esac
done
