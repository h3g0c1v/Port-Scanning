#!/bin/bash

# Este script automatiza la enumeración básica de una máquina al empezar
# Author: H3g0c1v

#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"


# Variables Globales
ip=$1 # Direccion IP destino
firstFile="allPorts"
ports="" # Almacenara todos los puertos abiertos
counter=""

# Muestra el banner
function banner() {
  echo "                                                                                              "
  echo "░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓████████▓▒░░▒▓██████▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      "
  echo "░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓████▓▒░▒▓█▓▒░░▒▓█▓▒░      "
  echo "░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░         ░▒▓█▓▒░░▒▓█▓▒▒▓█▓▒░       "
  echo "░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒▒▓███▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░         ░▒▓█▓▒░░▒▓█▓▒▒▓█▓▒░       "
  echo "░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░         ░▒▓█▓▒░ ░▒▓█▓▓█▓▒░        "
  echo "░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░ ░▒▓█▓▓█▓▒░        "
  echo "░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓████████▓▒░░▒▓██████▓▒░   ░▒▓█▓▒░  ░▒▓██▓▒░         "
  echo "                                                                                              "
}

# Capturando CTRL + C
function ctrl_c() {
  echo -e "\n\n${red}[+] Saliendo ...${end}"
  tput cnorm; exit 1
}

trap ctrl_c SIGINT

# Comprueba si la ejecucion del codigo se esta haciendo con el usuario root
function admin() {
  if [ $(id -u) -ne 0 ]; then
    echo -ne "\n${red}[!] Debes ejecutar el script como root. Pulse ENTER para continuar ...${end}" && read x
    exit 1
  fi
}

# Panel de ayuda
function helpPanel() {
  echo -e "\n${green}[i]${end} Use: $0 IP [--no-banner]"
  exit 0
}

# Comrprobando que los programas necesarios estan instalados
function checkProgram() {
  tput civis # Ocultamos el cursor
  program=$1
  counter+=1

  if [ "$(which $program)" == "" ]  ; then

    if [ $counter -eq 1 ]; then
      echo -e "\n------------------------------------------------------------------------------------------------\n"
    fi

    echo -e "${green}[i] INSTALLING ${purple}$program${end} ...${end}"
    sudo apt install $program -y &>/dev/null
  fi
  tput cnorm # Mostramos el cursor
}

# Extrae los puertos del fichero "allPorts" (firstFile)
function extractPorts(){
  tput civis # Ocultamos el cursor
  openPorts=$(cat $firstFile | grep "Ports:" | sed "s/  */\n/g" | tail -n +3 | grep -Eo "[0-9][0-9]*/" | sed "s/\///g" > .ports.tmp)

  for port in $(cat .ports.tmp); do
    if [ "$ports" == "" ]; then
      ports+=$port
    else
      ports+=",$port"
    fi

    echo -e "${yellow}[+]${end} Port ${blue}$port${end} open"
  done
  rm .ports.tmp
  tput cnorm # Mostramos el cursor
}

# Escaneo con nmap que muestra unicamente los puertos abiertos
function scan() {
  tput civis # Ocultamos el cursor
  echo -e "\n------------------------------------------------------------------------------------------------"
  echo -e "\n${green}[i] OPEN PORTS ...${end}\n"
  tput civis

  sudo nmap -p- --open --min-rate 5000 -sS -n -vvv -Pn $ip -oG $firstFile &>/dev/null
  extractPorts 

  echo -e "\n------------------------------------------------------------------------------------------------"
  tput cnorm # Mostramos el cursor
}

# Sobre los puertos abiertos encontrados anteriormente, busca sus versiones y servicios
function scan2() {
  tput civis # Ocultamos el cursor
  echo -e "\n${green}[i] VERSIONS AND SERVICES ...${end}\n"

  sudo nmap -sCV -p$ports $ip -oN targeted &>/dev/null
  cat targeted
  
  echo -e "\n------------------------------------------------------------------------------------------------"
  tput cnorm # Mostramos el cursor
}

# En caso de que haya puertos con http/s ejecuta el script http-enum sobre ellos
function scriptWeb() {
  tput civis # Ocultamos el cursor
  cat $firstFile | grep -Eo "Ports:.*" | tr ' ' '\n' | grep -E "[0-9][0-9]*/" | grep "http" | cut -f 1 -d "/" > .ports.tmp

  if [ "$(cat .ports.tmp)" == "" ]; then
    return 0
  fi

   echo -e "\n${green}[i] RUNNING SCRIPT ${end}${purple}http-enum.nse${end}${green} OVER OPEN HTTP/S PORTS [${purple} $(cat $firstFile | tr ' ' '\n' | grep http | cut -f 1 -d '/' | tr '\n' ' ')${end}${green}]${end}\n"

  portsToScriptScan=""
  for port in $(cat .ports.tmp); do
    if [ "$portsToScriptScan" != "" ]; then
      portsToScriptScan+=",$port"
    else
      portsToScriptScan+="$port"
    fi
  done

  sudo nmap --script http-enum -p$portsToScriptScan $ip -oN webScan &>/dev/null
  cat webScan
  echo -e "\n------------------------------------------------------------------------------------------------"

  whatWeb
}

# Si ha entrado en scriptWeb() entra aqui y ejecuta whatweb sobre los puertos http/s
function whatWeb() {
  echo -e "\n${green}[i] RUNNING ${end}${purple}whatweb${end}${green} ...${end}"

  for port in $(cat .ports.tmp); do
    echo -ne "\n${green}[+] PORT ${purple}$port${end}: "
    whatweb $ip:$port
  done
  tput cnorm # Mostramos el cursor
}

# PROGRAMA PRINCIPAL
admin

# Si no ha introducido al menos un parametro la ejecucion del script esta mal y le mostramos el panel de ayuda
if [ $# -lt 1 ]; then
  helpPanel
fi

# Si NO ha introducido el parametro --no-banner, le mostramos el banner
if [[ "$2" != "--no-banner" && "$3" != "--no-banner" ]]; then
  banner
fi

checkProgram "nmap"
checkProgram "whatweb"

scan # Enumerar los puertos abiertos
scan2 # Enumerar la version y servicios para los puertos abiertos
scriptWeb # En caso de que haya puertos HTTP, ejecutara el script http-enum y ejecutara el comando whatweb

echo -e "\n------------------------------------------------------------------------------------------------\n"

# Mostramos el cursos
tput cnorm
