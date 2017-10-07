# Este script es una biblioteca. Para invocarla desde use 'source log.sh'

# Guarde el nombre del log en la variable LOGNAME.
# eg: si quiere usar el log preparador.log, setee LOGNAME=preparador

if [ ! -v LOGS ]; then LOGS=dirconf; fi
if [ ! -d $LOGS ]; then mkdir $LOGS; fi

if [ ! -v LOGNAME ]; then LOGNAME=log; else LOGNAME+=".log"; fi
if [ -e $LOGS/$LOGNAME ] && [ ! -w $LOGS/$LOGNAME ]; then exit; fi

# Añade un registro al log de la forma "[yyyy-mm-dd hh:mm] <args>" donde args
# son los argumentos de la funcion.
function log() {
    echo [$(date "+%Y-%m-%d %H:%M")] "$@" >>$LOGS/$LOGNAME
}
