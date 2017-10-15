#! /usr/bin/env bash	

source log.sh
LOGFILE="validador.log";
NOMBREARCHOK="plasticos_emitidos_001"
NOMBREARCHNOK="plasticos_rechazados"

### verificacion de correcta informacion de conformacion de numeros 
### de la tarjeta

tarjetaCorrecta() {
	es_numero='^[0-9]+$';
if ! [[ $1 =~ $es_numero ]] ; then
   rechazados="ERROR: TARJETA con caracteres que No son un números"; return 1
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
	archi=$1
	while read -r lineas
	do
	listd=$(echo "$lineas" | tr ' ' '/')
	listda=$(echo "$listd" | cut -d '/' -f4)
	echo $listda
	echo $archi
	if [ $listda = $archi ];
	then
	cp $ACEPTADOS/$arch $RECHAZADOS
	echo "o";
	return 1
	fi	
	done <<< $listadoprocesados
	cp $ACEPTADOS/$arch $PROCESADOS
	return 0
	
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
		((contar++));
		fi
		done < ./aceptados/tx_tarjetas
		
	fi
	fi
((contador++));	
done < ./archivos/tx_tarjetas
		
}
##### si algun registro falta informacion o esta mal formado va ######
#####  a ser rechazado ###############################################
rechazados() {
rechazados=$1;
}


####### funcion para chequear existencia de carpeta ###
####### o crearla si no existe ########################

chequearExistenciaProcesados() {
if [ ! -v PROCESADOS ]; then PROCESADOS=./aceptados/procesados; fi
if [ ! -v ACEPTADOS ]; then ACEPTADOS=./aceptados; fi
if [ ! -v RECHAZADOS ]; then RECHAZADOS=./aceptados/rechazados; fi
if [ ! -v VALIDADOS ]; then VALIDADOS=./validados; fi

if [ ! -d $VALIDADOS ]; 
then 
mkdir $VALIDADOS;
fi

if [ ! -d $ACEPTADOS ]; 
then 
mkdir $ACEPTADOS;
fi

if [ ! -d $PROCESADOS ]; 
then 
mkdir ./$PROCESADOS;
fi
if [ ! -d $RECHAZADOS ]; 
then 
mkdir $RECHAZADOS;
fi
}
tieneInfo() {
	if [ -z $1 ];
	then
	rechazados="campo sin informacion"
	return 1;
	fi
	return 0;
}	
### funcion que busca la cuenta del archivo tx_tarjetas en cumae####

buscarCuenta(){
contador=0;
while read line;
do
	linea=$(echo -e "$line\n");
	cuenta=$(echo "$linea" | cut -d ';' -f2);
	if [ $contador -ne 0 ];
	then
	if [ $1 = $cuenta ];
	then
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
echo "PROCESANDO..."

while read -r lin
do
contador=0;
cuentaregistros=0;
contadoraceptados=0;
contadorrechazados=0;
arch=$(echo "$lin" | cut -d '/' -f3)
log "procesando $arch"
yaseproceso $arch
while read line;

do 
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
  if [ $contador -ne 0 ]; then
  ((cuentaregistros++))
  buscarCuenta $CUENTA 1;
	if [ $? -eq 1 ]; then 
	rechazados "ERROR: Cuenta no encontrada" 
	let aceptado=1;
	fi
	tieneInfo $documento;
	if [ $? -eq 1 ]; then 
	rechazados "ERROR: campo documento sin informacion" 
	let aceptado=1;
	fi
	tieneInfo $denominacion;
	if [ $? -eq 1 ]; then 
	rechazados "ERROR: campo denominacion sin informacion"
	let aceptado=1;
	fi
	tarjetaCorrecta $t1;
	if [ $? -eq 1 ]; then  
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi	
	tarjetaCorrecta $t2;
	if [ $? -eq 1 ]; then  
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi	
	tarjetaCorrecta $t3;
	if [ $? -eq 1 ]; then 
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi
	tarjetaCorrecta $t4;
	if [ $? -eq 1 ]; then
	rechazados "ERROR: cantidad de digitos incorrecta"
	let aceptado=1;
	fi
	aux=$(echo $fechadesde | cut -d '/' -f1);
	aux2=$(echo $fechadesde | cut -d '/' -f2);
	aux3=$(echo $fechadesde | cut -d '/' -f3);
	
	fechainicial=$aux3$aux2$aux;
	aux=$(echo $fechahasta | cut -d '/' -f1);
	aux2=$(echo $fechahasta | cut -d '/' -f2);
	aux3=$(echo $fechahasta | cut -d '/' -f3);
	aux4=$(echo $aux3 | cut -c 1-4);
	fechaf=$aux4$aux2$aux;
  if [[ ! $fechadesde =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]];
  then
  rechazados "ERROR: fecha con formato incorrecto"
  let aceptado=1;
  fi
  fechahasta="$aux/$aux2/$aux4";
  if [[ $fechahasta =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]];
  then
  	DIFERENCIA=$(( ($(date --date $fechaf +%s) - $(date --date $fechainicial +%s) )/(60*60*24) ))
	if [ $DIFERENCIA -lt 0 ];
	then
	rechazados "ERROR: la fecha inicial es mayor que la final"
	let aceptado=1;
	fi

  else
  rechazados "ERROR: fecha con formato incorrecto"
  let aceptado=1;
  fi

  nombredeinput="$arch";
  ## si el registro es aceptado se graba la salidaOk
  if [ $aceptado -eq 0 ];
  then
  buscarCuenta $CUENTA 0
  grabarDatosDenunciadaBloqueada $CUENTA
  buscarEntidadBancaria $entidad	
  ((contadoraceptados++))
  echo -n "$nombredeinput;$CUENTA;$estado;$denunciada;$bloqueada" | cat >> $VALIDADOS/$NOMBREARCHOK  
  echo -n "; ; ;VALIDADOR;$documento;$denominacion;$t1;$t2;$t3;$t4;$fechadesde;$aux/$aux2/$aux4" | cat >> $VALIDADOS/$NOMBREARCHOK 
  echo ";$doc;$den;$alta;$categoria;$limite;$entidad;$alias" | cat >> $VALIDADOS/$NOMBREARCHOK;	
  log "registro nº $cuentaregistros: aceptado,"
  else
  ((contadorrechazados++))
  ### si el registro no fue aceptado se graba la salidaNoOk
  echo "$nombredeinput;$rechazados;$CUENTA;$documento;$denominacion;$t1;$t2;$t3;$t4;$fechadesde;$aux/$aux2/$aux4" | cat >> $RECHAZADOS/$NOMBREARCHNOK
  log "registro nº $cuentaregistros: error! $rechazados,"
  fi
  fi	
  ((contador++))
done < $lin;
if [ $aceptado -eq 0 ]; then
((contador++))
log "total de registros leidos: $cuentaregistros"
log "total de registros aceptados $contadoraceptados"
log "archivo procesado $nombredeinput"
else 
log "total de registros rechazados $contadorrechazados"
log "archivo rechazado $nombredeinput $rechazados" 
fi
rm $ACEPTADOS/$arch
done <<<"$listado"
echo "FINALIZADO EL PROCESO"

	
