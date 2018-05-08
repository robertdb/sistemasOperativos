#! /usr/bin/env bash

if [ ! -v PID_DEMONIO ]; then echo "demonio no esta corriendo"; exit; fi

echo "Matando demonio pid" $PID_DEMONIO
kill $PID_DEMONIO
