#!/bin/bash

# FIRST MODULE:
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

# SECCOND MODULE:

##!/bin/bash
#
#set -euo pipefail # Salir en errores, variables no definidas y fallos en pipes
#
## Función para limpiar procesos en background al salir
#cleanup() {
#  if [[ -n "${scan_pid:-}" ]]; then
#    kill "$scan_pid" 2>/dev/null || true
#    bluetoothctl scan off >/dev/null 2>&1 || true
#  fi
#}
#trap cleanup EXIT
#
## Función para mostrar notificación de error
#notify_error() {
#  notify-send "Bluetooth Error" "$1" --urgency=critical
#}
#
## Verificar que bluetoothctl esté disponible
#if ! command -v bluetoothctl >/dev/null; then
#  notify_error "bluetoothctl no está instalado"
#  exit 1
#fi
#
## Verificar que wofi esté disponible
#if ! command -v wofi >/dev/null; then
#  notify_error "wofi no está instalado"
#  exit 1
#fi
#
## Obtener dispositivos emparejados
#get_paired_devices() {
#  bluetoothctl devices 2>/dev/null | while read -r _ mac name_part; do
#    # Reconstruir el nombre completo
#    name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/^\s*Name:/ {print $2; exit}' | sed 's/^[[:space:]]*//')
#    if [[ -n "$name" ]]; then
#      printf "%s|%s\n" "$mac" "$name"
#    fi
#  done
#}
#
## Obtener información del dispositivo conectado
#get_connected_device() {
#  local connected_info
#  connected_info=$(bluetoothctl info 2>/dev/null | head -1)
#  if [[ "$connected_info" =~ Device\ ([A-Fa-f0-9:]{17}) ]]; then
#    local mac="${BASH_REMATCH[1]}"
#    local name
#    name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/^\s*Name:/ {print $2; exit}' | sed 's/^[[:space:]]*//')
#    if [[ -n "$name" ]]; then
#      printf "%s|%s\n" "$mac" "$name"
#    fi
#  fi
#}
#
## Obtener dispositivos emparejados
#paired_devices=$(get_paired_devices)
#if [[ -z "$paired_devices" ]]; then
#  notify-send "Bluetooth" "No hay dispositivos emparejados"
#fi
#
## Obtener dispositivo conectado
#connected_device=$(get_connected_device)
#connected_mac=""
#connected_name=""
#if [[ -n "$connected_device" ]]; then
#  connected_mac=$(echo "$connected_device" | cut -d'|' -f1)
#  connected_name=$(echo "$connected_device" | cut -d'|' -f2)
#fi
#
## Construir menú
#menu_entries=""
#
## Añadir opción para emparejar nuevos dispositivos
#menu_entries+="🔍 Emparejar nuevo dispositivo\n"
#
## Añadir separador si hay dispositivos
#if [[ -n "$paired_devices" ]]; then
#  menu_entries+="──────────────────────\n"
#fi
#
## Construir menú de dispositivos emparejados
#while IFS='|' read -r mac name; do
#  [[ -z "$mac" ]] && continue
#  if [[ "$mac" == "$connected_mac" ]]; then
#    menu_entries+="🔗 $name (Conectado)\n"
#  else
#    menu_entries+="📱 $name\n"
#  fi
#done <<<"$paired_devices"
#
## Mostrar menú al usuario
#choice=$(echo -e "$menu_entries" | wofi --dmenu -p "🔵 Bluetooth" --width=400 --height=300)
#
## Si el usuario cancela
#if [[ -z "$choice" ]]; then
#  exit 0
#fi
#
## Función para emparejar nuevo dispositivo
#pair_new_device() {
#  notify-send "Bluetooth" "Escaneando dispositivos..." --expire-time=3000
#
#  # Iniciar escaneo
#  bluetoothctl scan on >/dev/null 2>&1 &
#  scan_pid=$!
#
#  # Esperar un poco para el escaneo
#  sleep 8
#
#  # Detener escaneo
#  kill "$scan_pid" 2>/dev/null || true
#  bluetoothctl scan off >/dev/null 2>&1
#  unset scan_pid
#
#  # Obtener todos los dispositivos disponibles
#  available_devices=$(bluetoothctl devices 2>/dev/null | while read -r _ mac name_part; do
#    name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/^\s*Name:/ {print $2; exit}' | sed 's/^[[:space:]]*//')
#    if [[ -n "$name" ]]; then
#      printf "%s|%s\n" "$mac" "$name"
#    fi
#  done)
#
#  # Filtrar dispositivos ya emparejados
#  new_devices=""
#  while IFS='|' read -r mac name; do
#    [[ -z "$mac" ]] && continue
#    if ! echo "$paired_devices" | grep -q "^$mac|"; then
#      new_devices+="$name|$mac\n"
#    fi
#  done <<<"$available_devices"
#
#  if [[ -z "$new_devices" ]]; then
#    notify-send "Bluetooth" "No se encontraron nuevos dispositivos"
#    return 1
#  fi
#
#  # Mostrar nuevos dispositivos para emparejar
#  pair_choice=$(echo -e "$new_devices" | cut -d'|' -f1 | wofi --dmenu -p "🔍 Seleccionar dispositivo" --width=400)
#
#  if [[ -z "$pair_choice" ]]; then
#    return 1
#  fi
#
#  # Obtener MAC del dispositivo seleccionado
#  pair_mac=$(echo -e "$new_devices" | grep "^$(printf '%s' "$pair_choice" | sed 's/[[\.*^$()+?{|]/\\&/g')|" | cut -d'|' -f2)
#
#  if [[ -z "$pair_mac" ]]; then
#    notify_error "No se pudo obtener la dirección MAC del dispositivo"
#    return 1
#  fi
#
#  # Intentar emparejar y conectar
#  notify-send "Bluetooth" "Emparejando con $pair_choice..."
#
#  if bluetoothctl pair "$pair_mac" >/dev/null 2>&1 &&
#    bluetoothctl trust "$pair_mac" >/dev/null 2>&1 &&
#    bluetoothctl connect "$pair_mac" >/dev/null 2>&1; then
#    notify-send "Bluetooth" "✅ Dispositivo emparejado y conectado: $pair_choice"
#    return 0
#  else
#    notify_error "❌ Error al emparejar con $pair_choice"
#    return 1
#  fi
#}
#
## Procesar la elección del usuario
#case "$choice" in
#"🔍 Emparejar nuevo dispositivo")
#  pair_new_device
#  ;;
#"🔗 $connected_name (Conectado)")
#  if [[ -n "$connected_mac" ]]; then
#    notify-send "Bluetooth" "Desconectando de $connected_name..."
#    if bluetoothctl disconnect "$connected_mac" >/dev/null 2>&1; then
#      notify-send "Bluetooth" "✅ Desconectado de $connected_name"
#    else
#      notify_error "❌ Error al desconectar de $connected_name"
#    fi
#  fi
#  ;;
#"──────────────────────")
#  # Separador seleccionado, no hacer nada
#  ;;
#*)
#  # Conectar a dispositivo seleccionado
#  # Limpiar el nombre (quitar emoji y estado)
#  clean_name=$(echo "$choice" | sed 's/^📱 //')
#
#  # Buscar MAC del dispositivo seleccionado
#  selected_mac=$(echo "$paired_devices" | grep "|$(printf '%s' "$clean_name" | sed 's/[[\.*^$()+?{|]/\\&/g')$" | cut -d'|' -f1)
#
#  if [[ -n "$selected_mac" ]]; then
#    notify-send "Bluetooth" "Conectando a $clean_name..."
#    if bluetoothctl connect "$selected_mac" >/dev/null 2>&1; then
#      notify-send "Bluetooth" "✅ Conectado a $clean_name"
#    else
#      notify_error "❌ Error al conectar con $clean_name"
#    fi
#  else
#    notify_error "No se pudo encontrar el dispositivo seleccionado"
#  fi
#  ;;
#esac

# THIRD MODULE:

#!/usr/bin/env bash
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
#
# Author: Nick Clyde (clydedroid)
#
# A script that generates a rofi menu that uses bluetoothctl to
# connect to bluetooth devices and display status info.
#
# Inspired by networkmanager-dmenu (https://github.com/firecat53/networkmanager-dmenu)
# Thanks to x70b1 (https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/system-bluetooth-bluetoothctl)
#
# Depends on:
#   Arch repositories: rofi, bluez-utils (contains bluetoothctl), bc

# Constants
divider="---------"
goback="Back"

# Checks if bluetooth controller is powered on
power_on() {
  if bluetoothctl show | grep -q "Powered: yes"; then
    return 0
  else
    return 1
  fi
}

# Toggles power state
toggle_power() {
  if power_on; then
    bluetoothctl power off
    show_menu
  else
    if rfkill list bluetooth | grep -q 'blocked: yes'; then
      rfkill unblock bluetooth && sleep 3
    fi
    bluetoothctl power on
    show_menu
  fi
}

# Checks if controller is scanning for new devices
scan_on() {
  if bluetoothctl show | grep -q "Discovering: yes"; then
    echo "Scan: on"
    return 0
  else
    echo "Scan: off"
    return 1
  fi
}

# Toggles scanning state
toggle_scan() {
  if scan_on; then
    kill $(pgrep -f "bluetoothctl --timeout 5 scan on")
    bluetoothctl scan off
    show_menu
  else
    bluetoothctl --timeout 5 scan on
    echo "Scanning..."
    show_menu
  fi
}

# Checks if controller is able to pair to devices
pairable_on() {
  if bluetoothctl show | grep -q "Pairable: yes"; then
    echo "Pairable: on"
    return 0
  else
    echo "Pairable: off"
    return 1
  fi
}

# Toggles pairable state
toggle_pairable() {
  if pairable_on; then
    bluetoothctl pairable off
    show_menu
  else
    bluetoothctl pairable on
    show_menu
  fi
}

# Checks if controller is discoverable by other devices
discoverable_on() {
  if bluetoothctl show | grep -q "Discoverable: yes"; then
    echo "Discoverable: on"
    return 0
  else
    echo "Discoverable: off"
    return 1
  fi
}

# Toggles discoverable state
toggle_discoverable() {
  if discoverable_on; then
    bluetoothctl discoverable off
    show_menu
  else
    bluetoothctl discoverable on
    show_menu
  fi
}

# Checks if a device is connected
device_connected() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Connected: yes"; then
    return 0
  else
    return 1
  fi
}

# Toggles device connection
toggle_connection() {
  if device_connected "$1"; then
    bluetoothctl disconnect "$1"
    device_menu "$device"
  else
    bluetoothctl connect "$1"
    device_menu "$device"
  fi
}

# Checks if a device is paired
device_paired() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Paired: yes"; then
    echo "Paired: yes"
    return 0
  else
    echo "Paired: no"
    return 1
  fi
}

# Toggles device paired state
toggle_paired() {
  if device_paired "$1"; then
    bluetoothctl remove "$1"
    device_menu "$device"
  else
    bluetoothctl pair "$1"
    device_menu "$device"
  fi
}

# Checks if a device is trusted
device_trusted() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Trusted: yes"; then
    echo "Trusted: yes"
    return 0
  else
    echo "Trusted: no"
    return 1
  fi
}

# Toggles device connection
toggle_trust() {
  if device_trusted "$1"; then
    bluetoothctl untrust "$1"
    device_menu "$device"
  else
    bluetoothctl trust "$1"
    device_menu "$device"
  fi
}

# Prints a short string with the current bluetooth status
# Useful for status bars like polybar, etc.
print_status() {
  if power_on; then
    printf ''

    paired_devices_cmd="devices Paired"
    # Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
    if (($(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l))); then
      paired_devices_cmd="paired-devices"
    fi

    mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
    counter=0

    for device in "${paired_devices[@]}"; do
      if device_connected "$device"; then
        device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

        if [ $counter -gt 0 ]; then
          printf ", %s" "$device_alias"
        else
          printf " %s" "$device_alias"
        fi

        ((counter++))
      fi
    done
    printf "\n"
  else
    echo ""
  fi
}

# A submenu for a specific device that allows connecting, pairing, and trusting
device_menu() {
  device=$1

  # Get device name and mac address
  device_name=$(echo "$device" | cut -d ' ' -f 3-)
  mac=$(echo "$device" | cut -d ' ' -f 2)

  # Build options
  if device_connected "$mac"; then
    connected="Connected: yes"
  else
    connected="Connected: no"
  fi
  paired=$(device_paired "$mac")
  trusted=$(device_trusted "$mac")
  options="$connected\n$paired\n$trusted\n$divider\n$goback\nExit"

  # Open rofi menu, read chosen option
  chosen="$(echo -e "$options" | $rofi_command "$device_name")"

  # Match chosen option to command
  case "$chosen" in
  "" | "$divider")
    echo "No option chosen."
    ;;
  "$connected")
    toggle_connection "$mac"
    ;;
  "$paired")
    toggle_paired "$mac"
    ;;
  "$trusted")
    toggle_trust "$mac"
    ;;
  "$goback")
    show_menu
    ;;
  esac
}

# Opens a rofi menu with current bluetooth status and options to connect
show_menu() {
  # Get menu options
  if power_on; then
    power="Power: on"

    # Human-readable names of devices, one per line
    # If scan is off, will only list paired devices
    devices=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)

    # Get controller flags
    scan=$(scan_on)
    pairable=$(pairable_on)
    discoverable=$(discoverable_on)

    # Options passed to rofi
    options="$devices\n$divider\n$power\n$scan\n$pairable\n$discoverable\nExit"
  else
    power="Power: off"
    options="$power\nExit"
  fi

  # Open rofi menu, read chosen option
  chosen="$(echo -e "$options" | $rofi_command "Bluetooth")"

  # Match chosen option to command
  case "$chosen" in
  "" | "$divider")
    echo "No option chosen."
    ;;
  "$power")
    toggle_power
    ;;
  "$scan")
    toggle_scan
    ;;
  "$discoverable")
    toggle_discoverable
    ;;
  "$pairable")
    toggle_pairable
    ;;
  *)
    device=$(bluetoothctl devices | grep "$chosen")
    # Open a submenu if a device is selected
    if [[ $device ]]; then device_menu "$device"; fi
    ;;
  esac
}

# Rofi command to pipe into, can add any options here
rofi_command="rofi -dmenu $* -p"

case "$1" in
--status)
  print_status
  ;;
*)
  show_menu
  ;;
esac
