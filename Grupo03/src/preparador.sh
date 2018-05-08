LOGFILE=preparador
source log.sh

GRUPO=$(pwd | sed "s-\(.*Grupo03\).*-\1-")

function reportar() {
    echo -e "\e[1;31m$1\e[0m"
    echo -e "\e[1;31mPara reparar la instalación corra el script './instalador.sh -r'\e[0m"
}

while read linea; do
    if [[ -z $linea ]]; then continue; fi

    key=$(echo "$linea" | cut -d- -f1)
    ruta=$(echo "$linea" | cut -d- -f2)
    user=$(echo "$linea" | cut -d- -f3)

    case "$key" in
        maestros) export MAESTROS=$ruta;;
        ejecutables) export EJECUTABLES=$ruta;;
        aceptados) export ACEPTADOS=$ruta;;
        rechazados) export RECHAZADOS=$ruta;;
        validados) export VALIDADOS=$ruta;;
        reportes) export REPORTES=$ruta;;
        logs) export LOGS=$ruta;;
    esac

    if [[ -z $flag ]]; then flag=$user; fi

    if [[ $flag != $user ]]; then
      reportar "Error de usuario, tiene que ser el mismo para todas rutas"
    fi
done < "$GRUPO/dirconf/configuracion.conf"

for x in MAESTROS EJECUTABLES ACEPTADOS RECHAZADOS VALIDADOS REPORTES LOGS; do
    if [ ! -v $x ]; then
        echo "no esta $x en archivo de configuracion"
    elif [ ! -d ${!x} ]; then
        reportar "directorio de $x no existe"
    fi
done

log "se crea la variable de ambiente DIRABUS"
echo "se crea la variable de ambiente DIRABUS"
export DIRABUS
read -p $'Defina el directorio de búsqueda: Grupo03/' -ei dirabus DIRABUS
DIRABUS="$GRUPO/$DIRABUS"
mkdir -p $DIRABUS
echo -e "\e[1;32mDirectorio de búsqueda creado correctamente.\e[0m"

log "cambio de permisos en MAESTROS y EJECUTABLES"
echo "cambio de permisos en MAESTROS y EJECUTABLES"
find "$MAESTROS" -type f -exec chmod u+r {} +
find "$EJECUTABLES" -type f -exec chmod u+x {} +

$EJECUTABLES/demonio.sh &
export PID_DEMONIO=$!0
echo "Demonio iniciado con id de proceso $PID_DEMONIO"
