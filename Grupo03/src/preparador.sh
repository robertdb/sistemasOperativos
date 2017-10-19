LOGFILE=preparador
source log.sh

GRUPO=$(pwd | sed "s-\(.*Grupo03\).*-\1-")

function reportar() {
    echo -e "\e[1;31m$1\e[0m"
    echo -e "\e[1;31mPara reparar la instalación corra el script './instalador.sh -r'\e[0m"
    log $1
}

declare -r ejecutables="ejecutables"
declare -r maestros="maestros"
declare -r aceptados="aceptados"
declare -r rechazados="rechazados"
declare -r validados="validados"
declare -r reportes="reportes"
declare -r logs="logs"

declare -A map


while read linea
do
    if [[ -z $linea ]]; then
      continue
    fi
    key=$(echo "$linea" | grep --only-matching '^[^-]*')

    user=$(echo "$linea" | sed 's#^[^-]*-[^-]*-\([^-]*\).*#\1#')

    if [[ $key == $maestros ]]; then
      maestro_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ $key == $ejecutables ]]; then
      ejecutables_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ $key == $aceptados ]]; then
      aceptados_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ $key == $rechazados ]]; then
      rechazados_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ $key == $validados ]]; then
      validados_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ $key == $reportes ]]; then
      reportes_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ $key == $logs ]]; then
      logs_ruta=$(echo "$linea" | sed 's#^[^-]*-\([^-]*\).*#\1#')
    fi

    if [[ -z $flag ]]; then
      flag=$user
    fi

    if [[ $flag != $user ]]; then
      reportar "Error de usuario, tiene que ser el mismo para todas rutas"
      exit 1
    fi

    map[$key]=$((${map[$key]} + 1))

done < "$GRUPO/dirconf/configuracion.conf"

declare -A mapErrors

#nombrar directorios faltantes, cortar ejecucion
  if [[ -z "${map[${ejecutables}]}" ]]; then
    reportar "No existe el directorio $ejecutables"
    exit 1
  fi
  if [[ -z "${map[${maestros}]}" ]]; then
    reportar "No existe el directorio $maestros";
    exit 1
  fi
  if [[ -z "${map[${aceptados}]}" ]]; then
    reportar "No existe el directorio $aceptados";
    exit 1
  fi
  if [[ -z "${map[${rechazados}]}" ]]; then
    reportar "No existe el directorio $rechazados";
    exit 1
  fi
  if [[ -z "${map[${validados}]}" ]]; then
    reportar "No existe el directorio $validados";
    exit 1
  fi
  if [[ -z "${map[${reportes}]}" ]]; then
    reportar "No existe el directorio $reportes";
    exit 1
  fi
  if [[ -z "${map[${logs}]}" ]]; then
    reportar "No existe el directorio $logs";
    exit 1
  fi


for i in "${!map[@]}"
do
  case $i in

    $ejecutables )
      ;;
    $maestros )
      ;;
    $aceptados )
      ;;
    $rechazados )
    ;;
    $validados )
    ;;
    $reportes )
    ;;
    $logs )
    ;;
    * ) mapErrors[$i]="Directorio $i inválido, verifique las rutas de configuración"
        continue
   ;;
  esac

  if [[ ${map[$i]} -gt 1 ]]; then
    mapErrors[$i]="Directorio $i esta duplicado"
  fi

done

if [[ ${#mapErrors[@]} > 0 ]]; then
  for i in "${!mapErrors[@]}"
  do
    reportar "${mapErrors[$i]}"
  done
  exit 1
fi

export DIRABUS
read -p $'Defina el directorio de búsqueda: Grupo03/' -ei dirabus DIRABUS
DIRABUS=$GRUPO/$DIRABUS

echo -e "\e[1;32mDirectorio de búsqueda creado correctamente.\e[0m"

log "se crea la variable de ambiente DIRABUS"

export MAESTROS=$maestro_ruta
log "se crea la variable de ambiente MAESTROS"

export EJECUTABLES=$ejecutables_ruta
log "se crea la variable de ambiente EJECUTABLES"

export ACEPTADOS=$aceptados_ruta
log "se crea la variable de ambiente ACEPTADOS"

export RECHAZADOS=$rechazados_ruta
log "se crea la variable de ambiente RECHAZADOS"

export VALIDADOS=$validados_ruta
log "se crea la variable de ambiente VALIDADOS"

export REPORTES=$reportes_ruta
log "se crea la variable de ambiente REPORTES"
export LOGS=$logs_ruta
log "se crea la variable de ambiente LOGS"

find "$MAESTRO" -type f -exec chmod u+r {} +
find "$EJECUTABLES" -type f -exec chmod u+x {} +

export PID_DEMONIO=./start_demonio.sh
