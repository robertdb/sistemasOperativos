#! /usr/bin/env bash

LOGFILE=demonio
source log.sh

source mv.sh

# Rechaza un archivo y registra el evento en el log.
#
# El segundo argumento es un mensaje opcional que se agrega al log.
function rechazar() {
    _mv $RECHAZADOS ${1:?"rechazar llamado sin argumentos"}
    log archivo rechazado: $(basename $1)${2:+, $2}
}

function aceptar() {
    _mv $ACEPTADOS ${1?"aceptar llamado sin argumentos"}
    log archivo aceptado: $(basename $1)
}

function procesarArchivo() {
    local name=$(basename $1)

    if ! [ -s $1 ]; then
        rechazar $1 "vacio"; return; fi

    if ! [[ $name =~ [^_]+_[^_]+\.txt ]]; then
        rechazar $1 "nombre mal formado"; return; fi
    local matching_entities=$( \
        tail --lines=+2 $MAESTROS/bamae \
        | cut --fields=1 --delimiter=\; \
        | grep "${name%_*}" \
    )
    if [[ $matching_entities == "" ]]; then
        rechazar $1 "entidad no reconocida"; return; fi

    # eliminar la extension y todo lo que este a la izquierda del _ (inclusive)
    local noext=${name%.*}
    local date=${noext#*_}
    if [[ $(date 2>&1 --date $date) =~ invalid ]]; then
        rechazar $1 "fecha mal formada"; return; fi
    if [[ $date > $(date "+%Y%m%d") ]]; then
        rechazar $1 "fecha pertenece al futuro"; return; fi

    if ! [[ $(file $1) =~ ASCII ]]; then
        rechazar $1 "no es ASCII"; return; fi

    aceptar $1
}

for (( i = 1; ; i++ )); do
    log "ciclo: " $i
    if [ $(($i%100)) -eq 0 ]; then truncate; fi

    sleep 10

    if [ -z "$(ls -A $DIRABUS)" ]; then continue; fi
    for file in $DIRABUS/*; do procesarArchivo $file; done
    
    if [ -z "$(ls -A $ACEPTADOS)" ]; then $EJECUTABLES/validador.sh; fi
done
