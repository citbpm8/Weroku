#!/bin/bash
set -e

FORBIDDEN_UTILS="socat nc netcat php lua telnet ncat cryptcat rlwrap msfconsole hydra medusa john hashcat sqlmap metasploit empire cobaltstrike ettercap bettercap responder mitmproxy evil-winrm chisel ligolo revshells powershell certutil bitsadmin smbclient impacket-scripts smbmap crackmapexec enum4linux ldapsearch onesixtyone snmpwalk zphisher socialfish blackeye weeman aircrack-ng reaver pixiewps wifite kismet horst wash bully wpscan commix xerosploit slowloris hping iodine iodine-client iodine-server"

PORT=${PORT:-8080}

if [ -z "$KOYEB_PUBLIC_DOMAIN" ]; then
    echo "KOYEB_PUBLIC_DOMAIN не установлен"
    exit 1
fi

keep_alive_local() {
    while true; do
        random_timeout=$((40 + RANDOM % 51))
        sleep "$random_timeout"
        if curl -s --max-time 5 "https://$KOYEB_PUBLIC_DOMAIN" >/dev/null; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Keep-alive запрос успешен (тайм-аут: ${random_timeout}с)"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] Keep-alive запрос не удался (тайм-аут: ${random_timeout}с)"
        fi
    done
}

monitor_forbidden() {
    while true; do
        for cmd in $FORBIDDEN_UTILS; do
            if command -v "$cmd" >/dev/null 2>&1; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] Обнаружена запрещенная утилита: $cmd"
                if apt-get purge -y "$cmd" >/dev/null 2>&1; then
                    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Запрещенная утилита удалена: $cmd"
                else
                    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] Не удалось удалить $cmd"
                fi
            fi
        done
        sleep 10
    done
}

start_hikka() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Запуск Hikka на порту $PORT"
    python3 -m hikka --port "$PORT" &
    HIKKA_PID=$!
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Hikka запущена с PID: $HIKKA_PID"
}

start_hikka
keep_alive_local &
monitor_forbidden &

tail -f /dev/null
