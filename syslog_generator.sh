#!/bin/bash

# Path to netcat
NC="/bin/nc"

# IP di destinazione
DEST_IP="192.168.190.11"
DEST_PORT=514

# IP sorgente simulati
SOURCES=("192.168.190.2" "192.168.190.3" "192.168.190.4" "192.168.190.5" "192.168.190.6" "192.168.190.7")

# Messaggi syslog simulati
MESSAGES=("Error Event" "Warning Event" "Info Event")

# Facilities e livelli syslog
FACILITIES=("kernel" "user" "mail" "system" "security" "syslog" "lpd" "nntp" "uucp" "time" "ftpd" "ntpd" "logaudit")
LEVELS=("emergency" "alert" "critical" "error" "warning" "notice" "info" "debug")
PRIORITIES=(0 1 2 3 4 5 6 7)

# Tempo tra invii
SLEEP_SECS=1
COUNT=1

# Protocollo: "udp", "tcp", "mixed"
PROTOCOL="mixed"

send_syslog() {
 local message=$1
    local proto=$2

    if [ "$proto" == "udp" ]; then
        echo "$message" | $NC -u -w 1 $DEST_IP $DEST_PORT
    elif [ "$proto" == "tcp" ]; then
        echo "$message" | $NC -w 1 $DEST_IP $DEST_PORT
    fi
}

while true; do
    for i in $(seq 1 $COUNT); do
        RANDOM_MESSAGE=${MESSAGES[$RANDOM % ${#MESSAGES[@]} ]}
        PRIORITY=${PRIORITIES[$RANDOM % ${#PRIORITIES[@]} ]}
        SOURCE=${SOURCES[$RANDOM % ${#SOURCES[@]} ]}
        FACILITY=${FACILITIES[$RANDOM % ${#FACILITIES[@]} ]}
        LEVEL=${LEVELS[$RANDOM % ${#LEVELS[@]} ]}

        TIMESTAMP=$(env LANG=us_US.UTF-8 date "+%b %d %H:%M:%S")
        SYSLOG_MSG="<$PRIORITY>$TIMESTAMP $SOURCE [$FACILITY.$LEVEL] service: $RANDOM_MESSAGE"

        case "$PROTOCOL" in
            "udp") send_syslog "$SYSLOG_MSG" "udp" ;;
            "tcp") send_syslog "$SYSLOG_MSG" "tcp" ;;
            "mixed")
                if (( RANDOM % 2 )); then
                    send_syslog "$SYSLOG_MSG" "udp"
                else
                    send_syslog "$SYSLOG_MSG" "tcp"
                fi
                ;;
            *) echo "Protocollo non valido: $PROTOCOL" ;;
        esac
    done
    sleep $SLEEP_SECS
done
