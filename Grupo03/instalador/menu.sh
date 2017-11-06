# Array con los directorios, este se deberia devolver como retorno
#LOGFILE="Instalador"
usuario=$(id -u -n)
#source ./log.sh


validar(){
#Valido que no sea dirconf
# if [ "$2" != "dirconf" ]; then
# Seteo variable 1 para si no esta repetido
#esta=1
#   for cosas in "${carpetas[@]}"; do
# Veo si esta repetido
#      if [ "$1" = "$cosas" ]; then
# Si esta repetido lo pongo en 0
#	 esta=0
#      fi
#   done
# fi
#return $esta

directorios=$(find "$GRUPO/" -type d)
#echo $directorios
esta=1
if [[ $2 == "dirconf/"* ]]; then
#si quiere crear subdirectorio en dirconf, retorno 2
  esta=2
else
  if [ -z "$2" -a "$2" != " " ];then
    esta=3
    return $esta
  fi
  if [ "$2" = "0" ]; then
    esta=3
    return $esta
  fi
 while read -r line
 do
   carpeta=$(echo "$line" | sed s-"$GRUPO/"-""-g)
     if [ "$2" = "$carpeta" ]; then
# Si esta repetido lo pongo en 0
	 esta=0
         return $esta
     fi
#    log "-$usuario-Instalador-INF-Mover $line a: ${carpetas[1]}"
 done <<<"$directorios"
   for cosas in "${carpetas[@]}"; do
# Veo si esta repetido
      if [ "$1" = "$cosas" ]; then
# Si esta repetido lo pongo en 0
	 esta=0
	 return $esta
      fi
   done
fi
return $esta

}

nombrarDirectorio(){
 mensaje "Directorio de $1 actual: ${carpetas[$2]}"
 mensaje "Para cambiarlo presione S cualquier otra tecla para cancelar"
 read opcion
 echo $opcion >> "$GRUPO/dirconf/salidaTerminal.log"
 if [ "$opcion" = "s" ]; then
#     mensaje "Ingrese nuevo directorio a partir de: $GRUPO"
#     mensaje "Ej: Nuevo Directorio"
#     mensaje "-----> $GRUPO/Nuevo Directorio"
#     read directorioNuevo
     read -p $"Defina el nuevo directorio de $1: $GRUPO/" -ei "" directorioNuevo
     echo $directorioNuevo >> "$GRUPO/dirconf/salidaTerminal.log"
     log "-$usuario-Instalador-INF-Informe nuevo directorio para $1"
     validar "$GRUPO/$directorioNuevo" $directorioNuevo $lugar
# le paso a ret lo que retorna la funcion validar
     ret=$?
#     if [ "$ret" = "1" ]; then
#       carpetas[$2]="$GRUPO/$directorioNuevo"
#       mensaje "Nuevo directorio para $1 creado: $GRUPO/$directorioNuevo"
#       log "-$usuario-Instalador-INF-Nuevo Directorio para $1 en: $GRUPO/$directorioNuevo"
#     else
#	mensaje "ERROR: Ya existe un directorio con ese nombre"
#	log "-$usuario-Instalador-ERROR-Ya existe un directorio con ese nombre $GRUPO/$directorioNuevo"
#        nombrarDirectorio $1 $2
#     fi

     case "$ret" in
      0)
	mensaje "ERROR: Ya existe un directorio con ese nombre"
	log "-$usuario-Instalador-ERROR-Ya existe un directorio con ese nombre $GRUPO/$directorioNuevo"
        nombrarDirectorio $1 $2
        ;;
      1)
       carpetas[$2]="$GRUPO/$directorioNuevo"
       mensaje "${carpetas[$2]}"
       mensaje "Nuevo directorio para $1 en: $GRUPO/$directorioNuevo"
       log "-$usuario-Instalador-INF-Nuevo Directorio para $1 en: $GRUPO/$directorioNuevo"
       ;;
      2)
	mensaje "ERROR: dirconf es un nombre reservado, no se puede crear subdirectorios"
	log "-$usuario-Instalador-ERROR-Ya existe un directorio con ese nombre $GRUPO/$directorioNuevo"
        nombrarDirectorio $1 $2
       ;;
       3)
       mensaje "ERROR: debe ingresar el nombre de la carpeta"
	     log "-$usuario-Instalador-ERROR-No ingreso nombre de carpeta"
       nombrarDirectorio $1 $2
       ;;
      esac


 fi
}


menu(){
#nombres=("ejecutables" "maestros" "aceptados" "rechazados" "validados" "reportes" "logs")
mensaje "------------------------------- MENU -----------------------------------"
mensaje "Seleccione una opcion para definir los directorios para la instalacion:"
mensaje "1- Ejecutables"
mensaje "2- Maestros"
mensaje "3- Aceptados"
mensaje "4- Rechazados"
mensaje "5- Validados"
mensaje "6- Reportes"
mensaje "7- Logs"
mensaje "8- Ver los directorios a instalarse"
mensaje "Para instalar presione la tecla I"
mensaje "Ingrese la letra C para salir sin instalar"
read opcion
echo $opcion >> "$GRUPO/dirconf/salidaTerminal.log"
log "-$usuario-Instalador-INF-Elija opcion del menu"
case $opcion in
 [1-7])
   lugar=$(($opcion-1))
   nombrarDirectorio "${nombres[$lugar]}" $lugar
#   mensaje "${carpetas[$lugar]}"
   menu
  ;;
 8)
  for ((i=0; i < 7;i++)); do
    mensaje "${nombres[$i]} a instalarse en: ${carpetas[$i]}"
  done
  menu
  ;;
 c)
   mensaje "Salio"
   exit 1
   mensaje "exit"
;;
 i)
  mensaje "proceso de instalacion"
  ;;
 *)
   clear
   mensaje "Opcion invalida"
   menu
esac

}
