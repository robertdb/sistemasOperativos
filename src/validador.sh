#! /usr/bin/env bash

### verificacion de correcta informacion de conformacion de numeros 
### de la tarjeta

tarjetaCorrecta() {
	es_numero='^[0-9]+$';
if ! [[ $1 =~ $es_numero ]] ; then
   echo "ERROR: No es un número" >&amp;2; return 1
fi
	#if [ $1 = "????" ];
	#then
	#echo "es correcto los 4 digitos"
	#return 0;
	#else
	#return 1;
	#fi
	
}

##### si algun registro falta informacion o esta mal formado va ######
#####  a ser rechazado ###############################################
rechazados() {
echo "rechazados";
}


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

tieneInfo() {
	if [ ! -z $1 ];
	then
	echo "tiene informacion la variable"
	echo $1;
	sleep 1;
	return 0;
	fi
	return 1;
}
### funcion que busca la cuenta del archivo tx_tarjetas en cumae####

buscarCuenta(){
echo "buscar cuenta en archivo maestro cumae";
contador=0;
while read line;
do
	echo $1;
	linea=$(echo -e "$line\n");
	cuenta=$(echo "$linea" | cut -d ';' -f2);
	if [ $contador -ne 0 ];
	then
	if [ $1 = $cuenta ];
	then
	echo "cuenta encontrada"
	sleep 1
	return 0;
	fi
	fi
	((contador++))
done < ./archivos/cumae
return 1;
}

chequearExistenciaProcesados
contador=0;
while read line;

do 
  
  LINEA=$(echo -e "$line\n");
  CUENTA=$(echo "$LINEA" | cut -d ';' -f2);
  documento=$(echo "$LINEA" | cut -d ';' -f3);
  denominacion=$(echo "$LINEA" | cut -d ';' -f4);
  t1=$(echo "$LINEA" | cut -d ';' -f5);
  t2=$(echo "$LINEA" | cut -d ';' -f6);
  t3=$(echo "$LINEA" | cut -d ';' -f7);
  t4=$(echo "$LINEA" | cut -d ';' -f8);
  sleep 1
  echo $contador;
  if [ $contador -ne 0 ]; then
  echo $CUENTA;
  buscarCuenta $CUENTA;
	if [ $? -eq 0 ]; then echo "cuenta no econtrada" 
	else 
	rechazados 
	fi
	tieneInfo $documento;
	if [ $? -eq 0 ]; then echo "documento con informacion"
	else 
	rechazados 
	fi
	tieneInfo $denominacion;
	if [ $? -eq 0 ]; then echo "denominacion con informacion" 
	else 
	rechazados 
	fi
	tarjetaCorrecta $t1 $t2 $t3 $t4;
	if [ $? -eq 0 ]; then echo "tarjeta con numeros bien formados" 
	else 
	rechazados 
	fi
	sleep 5;
	
  fi
  ((contador++))
done < ./archivos/tx_tarjetas



