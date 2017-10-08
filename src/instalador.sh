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
source ./archivoConfig.sh
source ./verificarPerl.sh
source ./menu.sh
export GRUPO
confi ruta1 ruta2 ruta3 ruta4 ruta5 ruta6 ruta7 

#Hago dirconf
if [ ! -d "$GRUPO/dirconf" ]; then
	echo "dirconf no creado"
#lo creo
	mkdir "$GRUPO/dirconf"
fi

chequearSistema
ret=$?
echo $ret
if [ "$ret" == 0 ]; then
    echo "no esta instalado el sistema "
    if [ "$1" == "-r" ]; then
	reparar
    else
        echo "no reparo"
	menu
    fi
fi
