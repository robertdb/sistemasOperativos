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

if [ ! -v LOGS ]; then
    echo "no esta log en archivo de configuracion"
elif [ ! -d $LOGS ]; then
    echo "directorio de logs no existe"
    reportar
fi

if [ ! -v MAESTROS ]; then
    echo "no esta maestros en archivo de configuracion"
elif [ ! -d $MAESTROS ]; then
    echo "directorio maestros no existe"
    reportar
fi

if [ ! -v EJECUTABLES ]; then
    echo "no esta ejecutables en archivo de configuracion"
elif [ ! -d $EJECUTABLES ]; then
    echo "directorio de ejecutables no existe"
    reportar
fi

if [ ! -v ACEPTADOS ]; then
    echo "no esta aceptados en archivo de configuracion"
elif [ ! -d $ACEPTADOS ]; then
    echo "directorio de aceptados no existe"
    reportar
fi

if [ ! -v RECHAZADOS ]; then
    echo "no esta rechazados en archivo de configuracion"
elif [ ! -d $RECHAZADOS ]; then
    echo "directorio de rechazados no existe"
    reportar
fi

if [ ! -v VALIDADOS ]; then
    echo "no esta validados en archivo de configuracion"
elif [ ! -d $VALIDADOS ]; then
    echo "directorio de validados no existe"
    reportar
fi

if [ ! -v REPORTES ]; then
    echo "no esta reportes en archivo de configuracion"
elif [ ! -d $REPORTES ]; then
    echo "directorio de reportes no existe"
    reportar
fi

log "se crea la variable de ambiente DIRABUS"
echo "se crea la variable de ambiente DIRABUS"
export DIRABUS
read -p $'Defina el directorio de búsqueda: Grupo03/' -ei dirabus DIRABUS
DIRABUS="$GRUPO/$DIRABUS"
echo -e "\e[1;32mDirectorio de búsqueda creado correctamente.\e[0m"

log "cambio de permisos en MAESTROS y EJECUTABLES"
echo "cambio de permisos en MAESTROS y EJECUTABLES"
find "$MAESTROS" -type f -exec chmod u+r {} +
find "$EJECUTABLES" -type f -exec chmod u+x {} +

export PID_DEMONIO=./start_demonio.sh
