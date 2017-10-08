# Creacion el archivo de configuracion.conf
# Esto se debe ejecutar cuando ya sepa donde se instalan las cosas

# se debe agregar con source ./archivoConfig.sh
# se debe recibir parametros tipo confi ruta1 ruta 2 ruta3 ruta4 ruta5 ruta6 ruta7
confi(){
#si existe el archivo lo borro
if [ -f "$GRUPO/dirconf/configuracion.conf" ]; then
    rm "$GRUPO/dirconf/configuracion.conf"
fi

rutas=()
for path in "$@";do
 rutas+=("$path");
done
usuario=$(id -u -n)
fecha=$(date '+%d/%m/%Y %H:%M')
IDENTIFICADOR=("ejecutables" "maestros" "aceptados" "rechazados" "validados" "reportes" "logs")
for ((i=0; i<= 6; i++))
do
#usa la variable GRUPO para establecer direccion del archivo
 echo "${IDENTIFICADOR[$i])}-"${rutas[$i]}"-$usuario-$fecha" >> "$GRUPO/dirconf/configuracion.conf"
done
}

