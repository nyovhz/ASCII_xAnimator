#!/bin/bash

# =====================================
# ASCII Animator para Git Bash Windows
# =====================================

# Parámetros
FOLDER="$1"  # Carpeta con los frames
FPS="$2"     # Velocidad en FPS
COLOR="$3"   # Color de texto

# Valores por defecto
if [ -z "$FPS" ]; then
  FPS=10
fi

if [ -z "$COLOR" ]; then
  COLOR="green"
fi

# Validaciones
if [ -z "$FOLDER" ]; then
  echo "Uso: $0 <carpeta_con_frames> [fps] [color]"
  exit 1
fi

if [ ! -d "$FOLDER" ]; then
  echo "La carpeta '$FOLDER' no existe."
  exit 1
fi

# Colores ANSI
case "$COLOR" in
  black)   ANSI="\033[0;30m" ;;
  red)     ANSI="\033[0;31m" ;;
  green)   ANSI="\033[0;32m" ;;
  yellow)  ANSI="\033[0;33m" ;;
  blue)    ANSI="\033[0;34m" ;;
  magenta) ANSI="\033[0;35m" ;;
  cyan)    ANSI="\033[0;36m" ;;
  white)   ANSI="\033[0;37m" ;;
  *)       ANSI="\033[0;32m" ;; # default green
esac

RESET="\033[0m"

# Calcular delay en segundos (float)
DELAY=$(echo "scale=3; 1 / $FPS" | bc)

# Loop infinito mostrando frames
while true; do
  for f in "$FOLDER"/frame-*.txt; do
    clear
    while IFS= read -r line; do
      echo -e "${ANSI}${line}${RESET}"
    done < "$f"
    
    # Delay usando sleep
    sleep 0.1
  done
done
