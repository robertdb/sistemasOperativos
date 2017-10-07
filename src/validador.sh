#! /bin/bash

####### funcion para chequear existencia de carpeta ###
####### o crearla si no existe ########################

chequearExistenciaProcesados() {
ACEPTADOS="aceptados";
if [ ! -v PROCESADOS ]; then PROCESADOS=procesados; fi
if [ ! -d ./$ACEPTADOS/$PROCESADOS ]; 
then 
mkdir ./$ACEPTADOS/$PROCESADOS;
fi
}

### funcion que busca la cuenta del archivo tx_tarjetas en cumae####

buscarCuenta(){
echo "buscar cuenta en archivo maestro cumae";
}

chequearExistenciaProcesados

while read line;
do 
  LINEA=$(echo -e "$line\n");
  CUENTA=$(echo "$LINEA" | cut -d ';' -f2);
  echo $CUENTA;
  #buscarCuenta(CUENTA);
done < ./archivos/tx_tarjetas



