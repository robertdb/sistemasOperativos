#! /usr/bin/env bash
export DIRABUS MAESTROS EJECUTABLES ACEPTADOS RECHAZADOS VALIDADOS REPORTES LOGS

# Si el demonio esta corriendo, su pid esta en PID_DEMONIO
if [ -v PID_DEMONIO ]; then echo $PID_DEMONIO; exit; fi

./demonio.sh &
echo $!
