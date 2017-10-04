GRUPO='~/Sistemas\ operativos/TP/Grupo3/'

chequearSistema () {
 echo "chequea sistema"
#retorna 0 si no esta instalado
 return 0
}

reparar(){
  echo "Reparar"
}
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
