# Este script es una biblioteca. Para invocarla use 'source log.sh'

# Guarde el nombre del log en la variable LOGFILE.
# eg: si quiere usar el log preparador.log, setee LOGFILE=preparador

if [ ! -v LOGFILE ]; then LOGFILE=log; else LOGFILE+=".log"; fi

# Añade un registro al log de la forma "[yyyy-mm-dd hh:mm] <args>" donde args
# son los argumentos de la funcion.
function log() {
    if [ ! -v LOGS ] || [ ! -d $LOGS ]; then return; fi
    echo [$(date "+%Y-%m-%d %H:%M")] "$@" >>$LOGS/$LOGFILE
}

function truncate() {
    # n es el primer argumento de truncate, o 50 por default.
    local n=${1:-50}
    tmp=$(mktemp)
    tail $LOGS/$LOGFILE -n $n >tmp
    mv tmp $LOGS/$LOGFILE
}
