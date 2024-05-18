#!/bin/bash

# Este script automatiza la enumeración básica de una máquina al empezar
# Author: H3g0c1v

#s
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

function admin() {
  if [ $(id -u) -ne 0 ]; then
    echo -ne "\n${red}[!] Debes ejecutar el script como root. Pulse ENTER para continuar ...${end}" && read x
    exit 1
  fi
}

function helpPanel() {
  echo -e "\n${green}[i]${end} Uso: $0 IP [--no-banner]"

  exit 0
}

function checkProgram() {
  tput civis
  program=$1
  counter+=1

  if [ "$(which $program)" == "" ]  ; then

    if [ $counter -eq 1 ]; then
      echo -e "\n------------------------------------------------------------------------------------------------\n"
    fi

    echo -e "${green}[i] INSTALLING ${purple}$program${end} ...${end}"
    sudo apt install $program -y &>/dev/null
  fi
}

function extractPorts(){
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
}

function scan() {
  tput civis
  echo -e "\n------------------------------------------------------------------------------------------------"
  echo -e "\n${green}[i] OPEN PORTS ...${end}\n"
  tput civis

  sudo nmap -p- --open --min-rate 5000 -sS -n -vvv -Pn $ip -oG $firstFile &>/dev/null
  extractPorts 

  echo -e "\n------------------------------------------------------------------------------------------------"
}

function scan2() {

  tput civis
  echo -e "\n${green}[i] VERSIONS AND SERVICES ...${end}\n"

  sudo nmap -sCV -p$ports $ip -oN targeted &>/dev/null
  cat targeted
  
  echo -e "\n------------------------------------------------------------------------------------------------"
}

function scriptWeb() {
  tput civis
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

function whatWeb() {
  tput civis
  echo -e "\n${green}[i] RUNNING ${end}${purple}whatweb${end}${green} ...${end}"

  for port in $(cat .ports.tmp); do
    echo -ne "\n${green}[+] PORT ${purple}$port${end}: "
    whatweb $ip:$port
  done
}

# MAIN
admin

if [ $# -lt 1 ]; then
  helpPanel
fi

if [[ "$2" != "--no-banner" && "$3" != "--no-banner" ]]; then
    banner
fi

checkProgram "nmap"
checkProgram "whatweb"

scan # Enumerar los puertos abiertos
scan2 # Enumerar la version y servicios para los puertos abiertos
scriptWeb # En caso de que haya puertos HTTP, ejecutara el script http-enum y ejecutara el comando whatweb

tput cnorm
