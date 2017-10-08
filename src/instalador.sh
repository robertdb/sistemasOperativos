##################################################################
## --------- FUNCIONES -----------####

chequearSistema () {
 echo "chequea sistema"
#retorna 0 si no esta instalado
 return 0
}

reparar(){
  echo "Reparar"
}

mover(){
 textos=$(find "$(pwd)" -type f -name "*.txt") 

 while read -r line
 do 
   echo "$line"
#   mv "$line" "${carpetas[1]}"
    log "-$usuario-Instalador-INF-Mover $line a: ${carpetas[1]}"
 done <<<"$textos"

  
 ejecutables=$(find "$(pwd)" -type f -iname "*.sh" -o -iname "*.pl")
 while read -r line
 do 
   echo "$line"
#   mv "$line" "${carpetas[0]}"
    log "-$usuario-Instalador-INF-Mover $line a: ${carpetas[0]}"
 done <<<"$ejecutables"
}







#Segun el enunciado debo pararme en un directorio llamado /Grupo3
# por eso se crea con el archivo comprimido esa carpeta.. nos paramos ahi para ejecutar todo
GRUPO=$(pwd)
if [ -f "$GRUPO/dirconf/salidaTerminal.log" ]; then
    rm "$GRUPO/dirconf/salidaTerminal.log"
fi
## Creo el directorio principal
#GRUPO='~/Sistemas\ operativos/TP/Grupo3'
# Expando el ~
#eval GRUPO=$GRUPO
#Chequeo si esta el directorio
#if [ ! -d "$GRUPO" ]; then
#	echo "no esta creado"
#lo creo
#	mkdir "$GRUPO"
#fi 
#if [ ! -d ~/Sistemas\ operativos/TP/Grupo3/ ]; then
#	echo "no esta creado x2 "
#fi 
source ./archivoConfig.sh
source ./verificarPerl.sh | tee -a "$GRUPO/dirconf/salidaTerminal.log"
source ./menu.sh
LOGFILE="Instalador"
usuario=$(id -u -n)
source ./log.sh
export GRUPO
#Hago dirconf
if [ ! -d "$GRUPO/dirconf" ]; then
	echo "dirconf no creado"
#lo creo
	mkdir "$GRUPO/dirconf"
fi | tee -a "$GRUPO/dirconf/salidaTerminal.log"
 
chequearSistema
ret=$?
echo $ret
if [ "$ret" == 0 ]; then
    echo "no esta instalado el sistema "
#verificar esto
    log "-$usuario-Instalador-INF-El sistema no esta instalado"
##
fi | tee -a "$GRUPO/dirconf/salidaTerminal.log"
case "$1" in

 "-r")
   reparar | tee -a "$GRUPO/dirconf/salidaTerminal.log"
   log "-$usuario-Instalador-INF-REPARAR sistema"
   ;;
  "")
   echo "no reparo"
   echo "a instalar"
   menu | tee -a "$GRUPO/dirconf/salidaTerminal.log"
#Despues de ejecutarse el menu ya se tiene los directorios listos para crearse
## Aca ya deberia poderse instalar los directorios

   confi "${carpetas[0]}" "${carpetas[1]}" "${carpetas[2]}" "${carpetas[3]}" "${carpetas[4]}" "${carpetas[5]}" "${carpetas[6]}"
   log "-$usuario-Instalador-INF-Creacion de configuracion.conf"
   echo "deberia instalar"
# Creo los directorios
   for cosas in "${carpetas[@]}"; do
#Esto despues borrarlo
     if [ ! -d "$cosas" ]; then
       log "-$usuario-Instalador-INF-Creacion del directorio: $cosas"
       mkdir "$cosas"
     fi
   done
   mover
   ;;

esac

#    if [ "$1" == "-r" ]; then
#	reparar
#    log "-$usuario-Instalador-INF-REPARAR sistema"
#    else
#        echo "no reparo"
#	echo "a instalar"
#	menu
#Despues de ejecutarse el menu ya se tiene los directorios listos para crearse
## Aca ya deberia poderse instalar los directorios

#       confi "${carpetas[0]}" "${carpetas[1]}" "${carpetas[2]}" "${carpetas[3]}" "${carpetas[4]}" "${carpetas[5]}" "${carpetas[6]}"
#       log "-$usuario-Instalador-INF-Creacion de configuracion.conf"
#       echo "deberia instalar"
# Creo los directorios
#       for cosas in "${carpetas[@]}"; do
#Esto despues borrarlo
#        if [ ! -d "$cosas" ]; then
#	log "-$usuario-Instalador-INF-Creacion del directorio: $cosas"
#	 mkdir "$cosas"
#        fi
#       done
### ACA deberia mover los archivos
#    mover




#    fi
#fi | tee -a "$GRUPO/dirconf/salidaTerminal.log"
