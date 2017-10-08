# Array con los directorios, este se deberia devolver como retorno
carpetas=("$GRUPO/bin" "$GRUPO/master" "$GRUPO/aceptados" "$GRUPO/rechazados" "$GRUPO/validados" "$GRUPO/reportes" "$GRUPO/logs")

validar(){
#Valido que no sea dirconf
 if [ "$2" != "dirconf" ]; then
# Seteo variable 1 para si no esta repetido
esta=1
   for cosas in "${carpetas[@]}"; do
# Veo si esta repetido
      if [ "$1" = "$cosas" ]; then
# Si esta repetido lo pongo en 0
	 esta=0
      fi
   done
 fi 
return $esta
}

nombrarDirectorio(){
 echo "Directorio de $1 actual: ${carpetas[$2]}"
 echo "Para cambiarlo presione S cualquier otra tecla para cancelar"
 read opcion
 if [ "$opcion" = "s" ]; then
     echo "Ingrese nuevo directorio a partir de: $GRUPO"
     echo "Ej: Nuevo Directorio"
     echo "-----> $GRUPO/Nuevo Directorio"
     read directorioNuevo
     validar "$GRUPO/$directorioNuevo" $directorioNuevo $lugar
# le paso a ret lo que retorna la funcion validar
     ret=$?
     if [ "$ret" = "1" ]; then
       carpetas[$2]="$GRUPO/$directorioNuevo"
       echo "Nuevo directorio para $1 creado: $GRUPO/$directorioNuevo"
     else 
	echo "ERROR: Ya existe un directorio con ese nombre"
        nombrarDirectorio $1 $2
     fi
 fi
}


menu(){
nombres=("ejecutables" "maestros" "aceptados" "rechazados" "validados" "reportes" "logs")
echo "------------------------------- MENU -----------------------------------" 
echo "Seleccione una opcion para definir los directorios para la instalacion:"
echo "1- Ejecutables"
echo "2- Maestros"
echo "3- Aceptados"
echo "4- Rechazados"
echo "5- Validados"
echo "6- Reportes"
echo "7- Logs"
echo "Ingrese la letra C para salir"
read opcion
#lugar=$($opcion-1)
case $opcion in 
 [1-7]) 
   lugar=$(($opcion-1))
   nombrarDirectorio "${nombres[$lugar]}" $lugar
#   echo "${carpetas[$lugar]}"
   menu
  ;;
 c)
   echo "Salio"
;;
 *) 
   clear
   echo "Opcion invalida"
   menu
esac


}
