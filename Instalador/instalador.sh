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
menu(){
ejecutables="$GRUPO/bin"
maestros="$GRUPO/master"
aceptados="$GRUPO/aceptados"
rechazados="$GRUPO/rechazados"
validados="$GRUPO/validados"
reportes="$GRUPO/reportes"
logs="$GRUPO/logs"
echo "Seleccione una opcion para definir los directorios para la instalacion:"
echo "1- Ejecutables"
echo "2- Maestros"
echo "3- Aceptados"
echo "4- Rechazados"
echo "5- Validados"
echo "6- Reportes"
echo "7- Logs"
read opcion

case $opcion in 
 1) echo "$ejecutables";;
 2) echo "$maestros";;
 3) echo "$aceptados";;
 4) echo "$rechazados";;
 5) echo "$validados";;
 6) echo "$reportes";;
 7) echo "$logs";;
esac


}



GRUPO='~/Sistemas\ operativos/TP/Grupo3'
# Expando el ~
eval GRUPO=$GRUPO
#Chequeo si esta el directorio
if [ ! -d "$GRUPO" ]; then
	echo "no esta creado"
#lo creo
	mkdir "$GRUPO"
fi
if [ ! -d ~/Sistemas\ operativos/TP/Grupo3/ ]; then
	echo "no esta creado x2 "
fi


#Hago dirconf
if [ ! -d "$GRUPO/dirconf" ]; then
	echo "dirconf no creado"
#lo creo
	mkdir "$GRUPO/dirconf"
fi

menu

chequearSistema
ret=$?
echo $ret
if [ "$ret" == 0 ]; then
    echo "no esta instalado "
    if [ "$1" == "-r" ]; then
	reparar
    else
        echo "no reparo"

    fi
fi
