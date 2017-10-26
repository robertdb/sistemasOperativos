#! /usr/bin/env bash
##################################################################
## --------- FUNCIONES -----------####

chequearSistema () {
 mensaje "chequea sistema"
#retorna 0 si no esta instalado
 if [ -e "$GRUPO/dirconf/configuracion.conf" ]; then
    return 1
 else
   return 0
 fi
}

log() {
    echo [$(date "+%Y-%m-%d %H:%M")] "$@" >> "$LOGS/$LOGFILE"
}

mensaje(){
  echo "$1" | tee -a "$GRUPO/dirconf/salidaTerminal.log"
}


reparar(){
  mensaje "Reparar"
  log "-$usuario-Instalador-INF-MODO REPARAR"
  carpetasACrear=$(cut -d- -f 2 "$GRUPO/dirconf/configuracion.conf")
  contador=0
  while read -r line
  do
#   echo "$line"
   carpetas[$contador]="$line"
    if [ ! -d "$line" ]; then
    mensaje "reparacion de carpeta $line"
#lo creo
       log "-$usuario-Instalador-INF-Reparacion de carpeta $line"
    mkdir "$line"
     fi
   contador+=1
  done <<<"$carpetasACrear"
  mover
}

mover(){
    textos=$(find "$GRUPO/archivos" -type f)

    while read -r line
    do
        cp "$line" "${carpetas[1]}" 2>/dev/null
        log "-$usuario-Instalador-INF-Mover $line a: ${carpetas[1]}"
    done <<<"$textos"


    ejecutables=$(find "$GRUPO/src" -type f -iname "*.sh" -o -iname "*.pl")
    while read -r line
    do
        cp "$line" "${carpetas[0]}" 2>/dev/null
        log "-$usuario-Instalador-INF-Mover $line a: ${carpetas[0]}"
    done <<<"$ejecutables"
}

instalacion(){

   menu
#Despues de ejecutarse el menu ya se tiene los directorios listos para crearse
## Aca ya deberia poderse instalar los directorios

   confi "${carpetas[0]}" "${carpetas[1]}" "${carpetas[2]}" "${carpetas[3]}" "${carpetas[4]}" "${carpetas[5]}" "${carpetas[6]}"
   log "-$usuario-Instalador-INF-Creacion de configuracion.conf"
   mensaje "deberia instalar"
# Creo los directorios
   for cosas in "${carpetas[@]}"; do
#Esto despues borrarlo
     if [ ! -d "$cosas" ]; then
       log "-$usuario-Instalador-INF-Creacion del directorio: $cosas"
       mkdir "$cosas"
     fi
   done
   mover


}
desinstalar(){
  mensaje "Desinstalar sistema"
  log "-$usuario-Instalador-INF-Desinstalacion de sistema"
  carpetasABorrar=$(cut -d- -f 2 "$GRUPO/dirconf/configuracion.conf")
  contador=0
  while read -r line
  do
#   echo "$line"
#   carpetas[$contador]="$line"
    if [ -d "$line" ]; then
    mensaje "borrar carpeta $line"
#lo creo
       log "-$usuario-Instalador-INF-Reparacion de carpeta $line"
    rm -f -r "$line"
     fi
#   contador+=1
  done <<<"$carpetasABorrar"
 mensaje "Borrar todo los logs de dirconf"
 log "-$usuario-Instalador-INF-Borrar logs de dirconf"
 rm "$GRUPO/dirconf/"*
}


############# ----- FIN FUNCIONES ------#####################################################




#Segun el enunciado debo pararme en un directorio llamado /Grupo3
# por eso se crea con el archivo comprimido esa carpeta.. nos paramos ahi para ejecutar todo
#estoy desde /Grupo3/instalador , los archivos se deberian crear en /Grupo3
ruta=$(pwd)
GRUPO=$"${ruta%/*}"
carpetas=("$GRUPO/bin" "$GRUPO/master" "$GRUPO/aceptados" "$GRUPO/rechazados" "$GRUPO/validados" "$GRUPO/reportes" "$GRUPO/logs")
LOGS="$GRUPO/dirconf"
LOGFILE="instalador.log"
nombres=("ejecutables" "maestros" "aceptados" "rechazados" "validados" "reportes" "logs")
#export GRUPO
#export carpetas
#if [ -f "$GRUPO/dirconf/salidaTerminal.log" ]; then
#    rm "$GRUPO/dirconf/salidaTerminal.log"
#fi

source ./archivoConfig.sh
source ./verificarPerl.sh
source ./menu.sh
usuario=$(id -u -n)
#Hago dirconf
if [ ! -d "$GRUPO/dirconf" ]; then
    mensaje "dirconf no creado"
#lo creo
    mkdir "$GRUPO/dirconf"
fi

chequearSistema
chequeo=$?

case "$1" in

 "-r")
   reparar
   log "-$usuario-Instalador-INF-REPARAR sistema"
   ;;
  "")

if [ "$chequeo" == 0 ]; then
    mensaje "no esta instalado el sistema "
#verificar esto
    log "-$usuario-Instalador-INF-El sistema no esta instalado"
    log "-$usuario-Instalador-INF-Modo instalacion normal"
##
   mensaje "no reparo"
#   mensaje "a instalar"

   instalacion

else
   mensaje "Ya esta instalado"
   log "-$usuario-Instalador-ERROR-Sistema ya instalado"
fi
   ;;

  "-i")
##
   mensaje "no reparo"
   mensaje "Instalacion forzada"
   log "-$usuario-Instalador-INF-Instalacion forzada"
   desinstalar
   instalacion
    ;;
  "-d")
   mensaje "Desinstalacion de sistema"
   log "-$usuario-Instalador-INF-MODO DESINSTALACION"
   desinstalar

  ;;


esac

