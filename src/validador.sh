#! /usr/bin/env bash

source log.sh
LOGFILE='validador.log';
LOG='dirconf';
## Variables que en realidad son globales ya que las pusieron en
## preparador pero por ahora para probar solo con mi script
## agregue estas variables que luego hay que borrar
ACEPTADOS="./aceptados"
RECHAZADOS="./aceptados/rechazados"
PROCESADOS="./aceptados/procesados"
VALIDADOS="./validados"
RECHAZADOS="./rechazados"
## variables de nombre de los archivos de salida ok y no ok
NOMBREARCHOK="plasticos_emitidos_001"
NOMBREARCHNOK="plasticos_rechazados"
### verificacion de correcta informacion de conformacion de numeros 
### de la tarjeta

tarjetaCorrecta() {
	es_numero='^[0-9]+$';
if ! [[ $1 =~ $es_numero ]] ; then
   echo "ERROR: No es un número"; return 1
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
yaseproceso(){
	while read -r lineas
	do
	listadoprocesa=$1;
	echo $listadoprocesa
	echo $arch
	sleep 5
	if [ $listadoprocesa = $arch ];
	then
	mv $ACEPTADOS/$arch $RECHAZADOS
	return 1
	else
	mv $ACEPTADOS/$arch $PROCESADOS
	return 0
	fi	
	done <<< $listadoprocesa
}


buscarEntidadBancaria() {
contador=0;
oldIFS=$IFS;
IFS=$'\n';
for linea in $(cat ./aceptados/bamae)
do
	enti=$(echo "$linea" | cut -d ';' -f1);
	if [ $contador -ne 0 ];
	then
	if [ $1 = $enti	 ];
	then
	alias=$(echo "$linea" | cut -d ';' -f2);
	break;
	fi
	fi
	((contador++))
done
IFS=$old_IFS;
}
## busca la cuenta y se queda con la ultima cuenta encontrada con ###
## su campo de denunciada y bloqueada ###############################
grabarDatosDenunciadaBloqueada() {
contador=0;
while read line;
do
	linea=$(echo -e "$line\n");
	cuenta=$(echo "$linea" | cut -d ';' -f2);
	if [ $contador -ne 0 ];
	then
		if [ $1 = $cuenta ];
		then
		#echo "$linea";
		denunciada=$(echo "$linea" | cut -d ';' -f11);
		bloqueada=$(echo "$linea" | cut -d ';' -f12);
		contar=0;
		while read line;
		do
		
		linea=$(echo -e "$line\n");
		cuenta=$(echo "$linea" | cut -d ';' -f2);
		if [ $1 = $cuenta ];
		then
		denunciada=$(echo "$linea" | cut -d ';' -f11);
		bloqueada=$(echo "$linea" | cut -d ';' -f12);
		echo "misma cuenta";
		((contar++));
		echo $contar;
		fi
		done < ./aceptados/tx_tarjetas
		
	fi
	fi
((contador++));	
done < ./archivos/tx_tarjetas
#echo -n ";$denunciada;$bloqueada" | cat >> 2
		
}
##### si algun registro falta informacion o esta mal formado va ######
#####  a ser rechazado ###############################################
rechazados() {
rechazados=$1;
echo "rechazados";
}


####### funcion para chequear existencia de carpeta ###
####### o crearla si no existe ########################

chequearExistenciaProcesados() {
ACEPTADOS="aceptados";
if [ ! -v PROCESADOS ]; then PROCESADOS=procesados; fi
if [ ! -d ./$PROCESADOS ]; 
then 
mkdir ./$PROCESADOS;
fi
}
tieneInfo() {
	if [ ! -z $1 ];
	then
	echo "tiene informacion la variable"
	echo "$1";
	return 0;
	fi
	return 1;
}	
### funcion que busca la cuenta del archivo tx_tarjetas en cumae####

buscarCuenta(){
echo "buscar 	cuenta en archivo maestro cumae";
contador=0;
while read line;
do
	linea=$(echo -e "$line\n");
	cuenta=$(echo "$linea" | cut -d ';' -f2);
	if [ $contador -ne 0 ];
	then
	if [ $1 = $cuenta ];
	then
	echo $1;
	echo $cuenta;
	if [ $2 -eq 0 ];
	then
	auxx=$(echo "$linea" | tr '\r' ';')
	estado=$(echo "$auxx" | cut -d ';' -f8);
	doc=$(echo "$linea" | cut -d ';' -f3);
	den=$(echo "$linea" | cut -d ';' -f4);
	alta=$(echo "$linea" | cut -d ';' -f5);
	categoria=$(echo "$linea" | cut -d ';' -f6);
	limite=$(echo "$linea" | cut -d ';' -f7);
	entidad=$(echo "$linea" | cut -d ';' -f1);	
#	echo -n "$estado" | cat >> 2;
	fi
	return 0;
	fi
	fi
	((contador++))
done < ./archivos/cumae
return 1;
}	
chequearExistenciaProcesados
listado=$(ls ./aceptados/*.txt);
listadoprocesados=$(ls ./aceptados/procesados/*.txt)
while read -r lin
do
contador=0;
arch=$(echo "$lin" | cut -d '/' -f3);
echo $archivo;
log "archivo procesado $archivo" 
while read line;

do 
#yaseproceso $listadoprocesados $arch
if [ $? -eq 1 ];
then
	continue
fi
  let aceptado=0;
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
  echo $contador;
  if [ $contador -ne 0 ]; then
  echo $CUENTA;
  echo $fechadesde;
  echo $fechahasta;
  buscarCuenta $CUENTA 1;
	if [ $? -eq 0 ]; then echo "cuenta econtrada" 
	else 
	rechazados "ERROR: Cuenta no encontrada" 
	let aceptado=1;
	fi
	tieneInfo $documento;
	if [ $? -eq 0 ]; then echo "documento con informacion"
	else 
	rechazados "ERROR: campo documento sin informacion" 
	let aceptado=1;
	fi
	tieneInfo $denominacion;
	if [ $? -eq 0 ]; then echo "denominacion con informacion"; 
	else 
	rechazados "ERROR: campo denominacion sin informacion"
	let aceptado=1;
	fi
	tarjetaCorrecta $t1;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi
	tarjetaCorrecta $t2;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi
	tarjetaCorrecta $t3;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi
	tarjetaCorrecta $t4;
	if [ $? -eq 0 ]; then echo "tiene 4 digitos bien formados" 
	else 
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
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
	rechazados "ERROR: la fecha inicial es mayor que la final"
	let aceptado=1;
	fi
  if [[ $fechadesde =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]];
  then
  echo "fecha en formato correcto dd-mm-aaaa";
  else
  rechazados "ERROR: fecha con formato incorrecto"
  let aceptado=1;
  fi
  fechahasta="$aux/$aux2/$aux4";
  if [[ $fechahasta =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]];
  then
  echo "fecha en formato correcto dd-mm-aaaa";
  else
  rechazados "ERROR: fecha con formato incorrecto"
  let aceptado=1;
  fi
  nombredeinput="$arch";
  ## si el registro es aceptado se graba la salidaOk
  if [ $aceptado -eq 0 ];
  then
  echo "entro";
  echo "cuenta es: $CUENTA";
  buscarCuenta $CUENTA 0
  grabarDatosDenunciadaBloqueada $CUENTA
  echo "entidad a buscar: $entidad";
  buscarEntidadBancaria $entidad	
  echo -n "$nombredeinput;$CUENTA;$estado;$denunciada;$bloqueada" | cat >> $VALIDADOS/$NOMBREARCHOK  
  echo -n "; ; ;VALIDADOR;$documento;$denominacion;$t1;$t2;$t3;$t4;$fechadesde;$aux/$aux2/$aux4" | cat >> $VALIDADOS/$NOMBREARCHOK 
  echo ";$doc;$den;$alta;$categoria;$limite;$entidad;$alias" | cat >> $VALIDADOS/$NOMBREARCHOK;	
  else
  ### si el registro no fue aceptado se graba la salidaNoOk
  echo "$nombredeinput;$rechazados;$CUENTA;$documento;$denominacion;$t1;$t2;$t3;$t4;$fechadesde;$aux/$aux2/$aux4" | cat >> $RECHAZADOS/$NOMBREARCHNOK
  fi
  fi	
  ((contador++))
  echo $archivo;
done < $lin;

done <<<"$listado"

