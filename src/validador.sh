#! /usr/bin/env bash

### verificacion de correcta informacion de conformacion de numeros 
### de la tarjeta

tarjetaCorrecta() {
	es_numero='^[0-9]+$';
if ! [[ $1 =~ $es_numero ]] ; then
   echo "ERROR: No es un número" >&amp;2; return 1
fi

parametro=$1;
digitos=$(echo "${#parametro}");
if [ $digitos -eq 4 ];
then
return 0;
else
return 1;
fi
	
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
  CUENTA=$(echo "$LINEA" | cut -d ';' -f1);
  documento=$(echo "$LINEA" | cut -d ';' -f2);
  denominacion=$(echo "$LINEA" | cut -d ';' -f3);
  t1=$(echo "$LINEA" | cut -d ';' -f4);
  t2=$(echo "$LINEA" | cut -d ';' -f5);
  t3=$(echo "$LINEA" | cut -d ';' -f6);
  t4=$(echo "$LINEA" | cut -d ';' -f7);
  fechadesde=$(echo "$LINEA" | cut -d ';' -f8);
  fechahasta=$(echo "$LINEA" | cut -d ';' -f9);
  sleep 1
  echo $contador;
  if [ $contador -ne 0 ]; then
  echo $CUENTA;
  echo $fechadesde;
  echo $fechahasta;
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
	tarjetaCorrecta $t1;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados 
	fi
	tarjetaCorrecta $t2;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados 
	fi
	tarjetaCorrecta $t3;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados 
	fi
	tarjetaCorrecta $t4;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados 
	fi
	aux=$(echo $fechadesde | cut -d '/' -f1);
	aux2=$(echo $fechadesde | cut -d '/' -f2);
	aux3=$(echo $fechadesde | cut -d '/' -f3);
	
	fechainicial=$aux3$aux2$aux;
	echo $fechainicial;
	aux=$(echo $fechahasta | cut -d '/' -f1);
	aux2=$(echo $fechahasta | cut -d '/' -f2);
	aux3=$(echo $fechahasta | cut -d '/' -f3);
	aux4=$(echo $aux3 | cut -c 1-4);
	echo $aux4;
	fechaf=$aux4$aux2$aux;
	echo $fechaf;
	DIFERENCIA=$(( ($(date --date $fechaf +%s) - $(date --date $fechainicial +%s) )/(60*60*24) ))
	echo "Diferencia: $DIFERENCIA"
	if [ $DIFERENCIA -ge 0 ];
	then
	echo "la fecha final es mayor que la inicial";
	else
	rechazados
	fi
  if [[ $fechadesde =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]];
  then
  echo "fecha en formato correcto dd-mm-aaaa";
  fi
  if [[ $fechahasta =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]];
  then
  echo "fecha en formato correcto dd-mm-aaaa";
  fi
  
  fi
  ((contador++))
done < ./archivos/003_20170916.txt



