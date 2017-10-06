# Creacion el archivo de configuracion.conf
# Esto se debe ejecutar cuando ya sepa donde se instalan las cosas
usuario=$(id -u -n)
fecha=$(date '+%d/%m/%Y %H:%M')
IDENTIFICADOR[0]="ejecutables"
IDENTIFICADOR[1]="maestros"
IDENTIFICADOR[2]="aceptados"
IDENTIFICADOR[3]="rechazados"
IDENTIFICADOR[4]="validados"
IDENTIFICADOR[5]="reportes"
IDENTIFICADOR[6]="logs"
for ((i=0; i<= 6; i++))
do
 echo "${IDENTIFICADOR[$i])}- RUTA - $usuario-$fecha"
done
