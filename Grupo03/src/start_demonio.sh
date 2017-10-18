#! /usr/bin/env bash
export DIRABUS MAESTROS EJECUTABLES ACEPTADOS RECHAZADOS VALIDADOS REPORTES LOGS
# Si el demonio esta corriendo, su pid esta en dirconf/pid_demonio
if [ -f dirconf/pid_demonio ]; then cat dirconf/pid_demonio; exit; fi

# Asegurarse que dirconf exista
if [ ! -d dirconf ]; then mkdir dirconf; fi

nohup 2>/dev/null ./demonio.sh >/dev/null &
echo $! | tee dirconf/pid_demonio
