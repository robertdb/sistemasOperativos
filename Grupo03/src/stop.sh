#! /usr/bin/env bash

if [ ! -f dirconf/pid_demonio ]; then echo "demonio no esta corriendo"; exit; fi

echo "Matando demonio pid" $(<dirconf/pid_demonio)
kill $(<dirconf/pid_demonio)
rm dirconf/pid_demonio
