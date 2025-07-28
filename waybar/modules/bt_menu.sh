#!/bin/bash

# # Escanea dispositivos disponibles
# bluetoothctl scan on >/dev/null &
# sleep 3
# bluetoothctl scan off >/dev/null
#
# # Obtiene lista de dispositivos únicos
# devices=$(bluetoothctl devices | awk '{print $2 "|" substr($0, index($0,$3))}')
#
# # Si no hay dispositivos, salir
# if [[ -z "$devices" ]]; then
#   notify-send "Bluetooth" "No hay dispositivos disponibles"
#   exit 0
# fi
#
# # Mostrar menú con wofi (puedes reemplazar por rofi si prefieres)
# choice=$(echo "$devices" | cut -d'|' -f2 | wofi --dmenu -p "Dispositivos Bluetooth")
#
# # Obtener MAC a partir de nombre seleccionado
# mac=$(echo "$devices" | grep "|$choice" | cut -d'|' -f1)
#
# # Conectar al dispositivo seleccionado
# if [[ -n "$mac" ]]; then
#   bluetoothctl connect "$mac"
#   notify-send "Bluetooth" "Conectando a $choice"
# fi

#!/bin/bash

set -euo pipefail # Salir en errores, variables no definidas y fallos en pipes

# Función para limpiar procesos en background al salir
cleanup() {
  if [[ -n "${scan_pid:-}" ]]; then
    kill "$scan_pid" 2>/dev/null || true
    bluetoothctl scan off >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

# Función para mostrar notificación de error
notify_error() {
  notify-send "Bluetooth Error" "$1" --urgency=critical
}

# Verificar que bluetoothctl esté disponible
if ! command -v bluetoothctl >/dev/null; then
  notify_error "bluetoothctl no está instalado"
  exit 1
fi

# Verificar que wofi esté disponible
if ! command -v wofi >/dev/null; then
  notify_error "wofi no está instalado"
  exit 1
fi

# Obtener dispositivos emparejados
get_paired_devices() {
  bluetoothctl devices 2>/dev/null | while read -r _ mac name_part; do
    # Reconstruir el nombre completo
    name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/^\s*Name:/ {print $2; exit}' | sed 's/^[[:space:]]*//')
    if [[ -n "$name" ]]; then
      printf "%s|%s\n" "$mac" "$name"
    fi
  done
}

# Obtener información del dispositivo conectado
get_connected_device() {
  local connected_info
  connected_info=$(bluetoothctl info 2>/dev/null | head -1)
  if [[ "$connected_info" =~ Device\ ([A-Fa-f0-9:]{17}) ]]; then
    local mac="${BASH_REMATCH[1]}"
    local name
    name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/^\s*Name:/ {print $2; exit}' | sed 's/^[[:space:]]*//')
    if [[ -n "$name" ]]; then
      printf "%s|%s\n" "$mac" "$name"
    fi
  fi
}

# Obtener dispositivos emparejados
paired_devices=$(get_paired_devices)
if [[ -z "$paired_devices" ]]; then
  notify-send "Bluetooth" "No hay dispositivos emparejados"
fi

# Obtener dispositivo conectado
connected_device=$(get_connected_device)
connected_mac=""
connected_name=""
if [[ -n "$connected_device" ]]; then
  connected_mac=$(echo "$connected_device" | cut -d'|' -f1)
  connected_name=$(echo "$connected_device" | cut -d'|' -f2)
fi

# Construir menú
menu_entries=""

# Añadir opción para emparejar nuevos dispositivos
menu_entries+="🔍 Emparejar nuevo dispositivo\n"

# Añadir separador si hay dispositivos
if [[ -n "$paired_devices" ]]; then
  menu_entries+="──────────────────────\n"
fi

# Construir menú de dispositivos emparejados
while IFS='|' read -r mac name; do
  [[ -z "$mac" ]] && continue
  if [[ "$mac" == "$connected_mac" ]]; then
    menu_entries+="🔗 $name (Conectado)\n"
  else
    menu_entries+="📱 $name\n"
  fi
done <<<"$paired_devices"

# Mostrar menú al usuario
choice=$(echo -e "$menu_entries" | wofi --dmenu -p "🔵 Bluetooth" --width=400 --height=300)

# Si el usuario cancela
if [[ -z "$choice" ]]; then
  exit 0
fi

# Función para emparejar nuevo dispositivo
pair_new_device() {
  notify-send "Bluetooth" "Escaneando dispositivos..." --expire-time=3000

  # Iniciar escaneo
  bluetoothctl scan on >/dev/null 2>&1 &
  scan_pid=$!

  # Esperar un poco para el escaneo
  sleep 8

  # Detener escaneo
  kill "$scan_pid" 2>/dev/null || true
  bluetoothctl scan off >/dev/null 2>&1
  unset scan_pid

  # Obtener todos los dispositivos disponibles
  available_devices=$(bluetoothctl devices 2>/dev/null | while read -r _ mac name_part; do
    name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/^\s*Name:/ {print $2; exit}' | sed 's/^[[:space:]]*//')
    if [[ -n "$name" ]]; then
      printf "%s|%s\n" "$mac" "$name"
    fi
  done)

  # Filtrar dispositivos ya emparejados
  new_devices=""
  while IFS='|' read -r mac name; do
    [[ -z "$mac" ]] && continue
    if ! echo "$paired_devices" | grep -q "^$mac|"; then
      new_devices+="$name|$mac\n"
    fi
  done <<<"$available_devices"

  if [[ -z "$new_devices" ]]; then
    notify-send "Bluetooth" "No se encontraron nuevos dispositivos"
    return 1
  fi

  # Mostrar nuevos dispositivos para emparejar
  pair_choice=$(echo -e "$new_devices" | cut -d'|' -f1 | wofi --dmenu -p "🔍 Seleccionar dispositivo" --width=400)

  if [[ -z "$pair_choice" ]]; then
    return 1
  fi

  # Obtener MAC del dispositivo seleccionado
  pair_mac=$(echo -e "$new_devices" | grep "^$(printf '%s' "$pair_choice" | sed 's/[[\.*^$()+?{|]/\\&/g')|" | cut -d'|' -f2)

  if [[ -z "$pair_mac" ]]; then
    notify_error "No se pudo obtener la dirección MAC del dispositivo"
    return 1
  fi

  # Intentar emparejar y conectar
  notify-send "Bluetooth" "Emparejando con $pair_choice..."

  if bluetoothctl pair "$pair_mac" >/dev/null 2>&1 &&
    bluetoothctl trust "$pair_mac" >/dev/null 2>&1 &&
    bluetoothctl connect "$pair_mac" >/dev/null 2>&1; then
    notify-send "Bluetooth" "✅ Dispositivo emparejado y conectado: $pair_choice"
    return 0
  else
    notify_error "❌ Error al emparejar con $pair_choice"
    return 1
  fi
}

# Procesar la elección del usuario
case "$choice" in
"🔍 Emparejar nuevo dispositivo")
  pair_new_device
  ;;
"🔗 $connected_name (Conectado)")
  if [[ -n "$connected_mac" ]]; then
    notify-send "Bluetooth" "Desconectando de $connected_name..."
    if bluetoothctl disconnect "$connected_mac" >/dev/null 2>&1; then
      notify-send "Bluetooth" "✅ Desconectado de $connected_name"
    else
      notify_error "❌ Error al desconectar de $connected_name"
    fi
  fi
  ;;
"──────────────────────")
  # Separador seleccionado, no hacer nada
  ;;
*)
  # Conectar a dispositivo seleccionado
  # Limpiar el nombre (quitar emoji y estado)
  clean_name=$(echo "$choice" | sed 's/^📱 //')

  # Buscar MAC del dispositivo seleccionado
  selected_mac=$(echo "$paired_devices" | grep "|$(printf '%s' "$clean_name" | sed 's/[[\.*^$()+?{|]/\\&/g')$" | cut -d'|' -f1)

  if [[ -n "$selected_mac" ]]; then
    notify-send "Bluetooth" "Conectando a $clean_name..."
    if bluetoothctl connect "$selected_mac" >/dev/null 2>&1; then
      notify-send "Bluetooth" "✅ Conectado a $clean_name"
    else
      notify_error "❌ Error al conectar con $clean_name"
    fi
  else
    notify_error "No se pudo encontrar el dispositivo seleccionado"
  fi
  ;;
esac
