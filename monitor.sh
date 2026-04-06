#!/bin/bash

# --- CONFIGURATION ---
MUSIC_PATH="/"
MANUAL_FAN=0

# --- EXIT CLEANUP ---
cleanup() {
  tput cnorm # Restore cursor
  clear
  # Safety: Return fan to Auto-control on exit
  echo 0 | sudo tee /sys/class/thermal/cooling_device0/cur_state > /dev/null 2>&1
  echo "Monitor stopped. Fan returned to Auto. System Clean."
  exit 0
}
trap cleanup SIGINT

# --- INITIAL SETUP ---
tput civis   # Hide cursor
clear

while true; do
  tput cup 0 0 # Reset cursor to top-left

  # --- 1. SYSTEM STATS ---
  TEMP=$(vcgencmd measure_temp | cut -d= -f2)
  VOLT=$(vcgencmd measure_volts | cut -d= -f2)
  UPTIME=$(uptime -p | sed 's/up //')
  IP_ADDR=$(hostname -I | awk '{print $1}')

  # --- 2. NETWORK AUTO-DETECT ---
  NET_IF=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')

  if [ -n "$NET_IF" ]; then
    RX1=$(cat /sys/class/net/"$NET_IF"/statistics/rx_bytes)
    TX1=$(cat /sys/class/net/"$NET_IF"/statistics/tx_bytes)

    RX_DIFF=$(( ($RX1 - ${PREV_RX:-$RX1}) / 1024 ))
    TX_DIFF=$(( ($TX1 - ${PREV_TX:-$TX1}) / 1024 ))
    PREV_RX=$RX1
    PREV_TX=$TX1

    [ "$RX_DIFF" -gt 1024 ] && DOWN=$(awk "BEGIN {printf \"%.2f MB/s\", $RX_DIFF/1024}") || DOWN="${RX_DIFF} KB/s"
    [ "$TX_DIFF" -gt 1024 ] && UP=$(awk "BEGIN {printf \"%.2f MB/s\", $TX_DIFF/1024}") || UP="${TX_DIFF} KB/s"
  else
    DOWN="Offline"; UP="Offline"
  fi

  # --- 3. RESOURCE USAGE ---
  CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%
  MEM_USED=$(free -m | awk '/Mem:/ { print $3 }')
  MEM_TOTAL=$(free -m | awk '/Mem:/ { print $2 }')
  DISK_USAGE=$(df -h "$MUSIC_PATH" | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
  DOCKER_COUNT=$(docker ps -q | wc -l)

  # --- 4. INTERACTIVE FAN LOGIC ---
  if [ -f /sys/class/thermal/cooling_device0/cur_state ]; then
    if [ "$MANUAL_FAN" -eq 1 ]; then
      echo 1 | sudo tee /sys/class/thermal/cooling_device0/cur_state > /dev/null 2>&1
      FAN_S="\033[1;32mMANUAL ON\033[0m"
    else
      FAN_VAL=$(cat /sys/class/thermal/cooling_device0/cur_state)
      [ "$FAN_VAL" -gt 0 ] && FAN_S="\033[1;32mAUTO ON \033[0m" || FAN_S="\033[1;31mAUTO OFF\033[0m"
    fi
  else
    FAN_S="N/A"
  fi

  # --- 5. LIVE HARDWARE HEALTH ---
  ACTUAL_KHZ=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq 2>/dev/null)
  if [ -n "$ACTUAL_KHZ" ]; then
    # Convert KHz to GHz (KHz / 1,000,000)
    ARM_GHZ=$(echo "$ACTUAL_KHZ" | awk '{printf "%.1f", $1/1000000}')
  else
    # Fallback
    ARM_RAW=$(vcgencmd measure_clock arm | cut -d= -f2)
    ARM_GHZ=$(echo "$ARM_RAW" | awk '{printf "%.1f", $1/1000000000}')
  fi

  THROTTLED_RAW=$(vcgencmd get_throttled | cut -d= -f2)
  [ "$THROTTLED_RAW" = "0x0" ] && THR="\033[1;32mNO\033[0m " || THR="\033[1;31mYES\033[0m"

  # --- 6. DISPLAY ---
  echo -e "\033[1;34m================= KYLE'S PI MONITOR ==================\033[0m\033[K"
  echo -e " Local IP    : \033[1;33m$IP_ADDR\033[0m\033[K"
  echo -e " Uptime      : $UPTIME\033[K"
  echo -e " Temperature : $TEMP\033[K"
  echo -e " Fan Status  : $FAN_S\033[K"
  echo -e "------------------------------------------------------\033[K"
  echo -e " CPU Load    : $CPU_LOAD\033[K"
  echo -e " Memory      : ${MEM_USED}MB / ${MEM_TOTAL}MB\033[K"
  echo -e " Disk Space  : $DISK_USAGE\033[K"
  echo -e " Network     : ↓ $DOWN  ↑ $UP\033[K"
  echo -e " Docker      : $DOCKER_COUNT Containers Running\033[K"
  echo -e "\033[1;34m------------------------------------------------------\033[0m\033[K"
  echo -e " CPU Clock   : \033[1;35m$ARM_GHZ GHz\033[0m\033[K"
  echo -e " Voltage     : $VOLT\033[K"
  echo -e " Throttled   : $THR\033[K"
  echo -e "\033[1;34m======================================================\033[0m\033[K"
  echo -e " [F] Toggle Manual Fan | [Ctrl+C] Stop & Reset Fan\033[K"
  echo -e " Updated: $(date +%H:%M:%S)\033[K"

  # --- 7. INPUT LISTENER ---
  read -t 1 -n 1 key
  if [[ $key == "f" || $key == "F" ]]; then
    if [ "$MANUAL_FAN" -eq 0 ]; then
      MANUAL_FAN=1
    else
      MANUAL_FAN=0
      echo 0 | sudo tee /sys/class/thermal/cooling_device0/cur_state > /dev/null 2>&1
    fi
  fi
done
