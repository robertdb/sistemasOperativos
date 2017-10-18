#!/usr/bin/perl


use Time::Piece;

$DIR_INPUT = "./validados";

# obtengo el archivo a procesar
my $file_input ="plasticos_emitidos_000.txt";
opendir(DIR, $DIR_INPUT) or die $!;

while (my $file = readdir(DIR)) {
	next unless (-f "$DIR_INPUT/$file");
    if ($file_input lt $file){
    	$file_input = $file;
    }
}
closedir(DIR);


my $secuence;
if ( $file_input =~ /\_.*\_(.*?)\./ )
{
    $secuence = $1;
}


$file_input = "$DIR_INPUT/$file_input";
open(ENTRADA, $file_input) || die "ERROR no se pudo abrir el archivo";


$DIR_OUTPUT = "./reportes";
$FILE_OUTPUT_BASE = "plasticos_distribucion_sec";

$file_output = "$DIR_OUTPUT/$FILE_OUTPUT_BASE$secuence.txt";
open($SALIDA, '>', $file_output) or die "ERROR no se pudo abrir el archivo '$file_output' $!";


($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;

$year += 1900;
$mon++;

my $fecha_actual = "$mday/$mon/$year";
print "fecha actual: $fecha_actual\n";

$mday+=10;

#my $fecha_actual_10day = "$mday/$mon/$year";
#print "fecha actual_10day: $fecha_actual_10day\n";

print  "===========================================================\n";
print  "inicio de proceso...\n\n";
print  "archivo a procesar: $file_input\n";
print  "archivo a generar : $file_output\n";

my $list;
my $cond_dist;
my $cantidad = 0;
while ($row=<ENTRADA>){
	 next if $. == 1; # salteamos la descripcion de las columnas

	@list = split( /(;)/, $row);

	$cond_dist = "DISTRIBUCION ESTANDAR";

	# cond_dist de la cuenta: condiciones 1, 2, 3
	if( $list[4] eq "BAJA"){
		#print "estado de la cuenta: $list[4]\n";
		$cond_dist = "NO DISTRIBUIR, la cuenta esta dada de BAJA";
	}
	else{
		if( $list[4] eq "CTX"){
			#print "estado de la cuenta: $list[4]\n";
			$cond_dist = "NO DISTRIBUIR, la cuenta es CONTENCIOSA";
		}
		else{
			if( $list[4] eq "JUD"){
				#print "estado de la cuenta: $list[4]\n";
				$cond_dist = "NO DISTRIBUIR, la cuenta es JUDICIAL";
			}
			else{
				# estado bloqueada: condicion 4
				if( $list[10] == 1){
					#print "estado bloqueada\n";
					$cond_dist = "RETENER, la tarjeta fue BLOQUEADA";
				}
				else{
					# fecha hasta: condicion 5
					my $dateformat = "%d/%m/%Y";
					#print "fecha: $list[32]\n";
					$date = Time::Piece->strptime($list[32], $dateformat);
					$date_actual = Time::Piece->strptime($fecha_actual, $dateformat);
					if( $date < $date_actual){
						$cond_dist = "NO DISTRIBUIR, tarjeta VENCIDA";
					}
					else{
						# fecha hasta: condicion 6
						$date_actual_10day = Time::Piece->strptime($fecha_actual_10day, $dateformat);
						if( $date < $date_actual_10day){
							$cond_dist = "NO DISTRIBUIR, ventana de distribucion insuficiente";
						}
						else{
							# estado denunciada: condicion 7
							if( $list[8] == 1){
								$cond_dist = "DISTRIBUCION URGENTE";
							}
						}
					}
				}
			}

		}
	}

	# update de los campos
	$list[12] = $cond_dist;
	$list[14] = $fecha_actual;
	$list[16] = "VALIDADOR";

	#print  "### condicion: $cond_dist\n";

	# actualizacion de archivo
	print $SALIDA join('', @list);
	$cantidad++;
}

close(ENTRADA);
close(SALIDA);
print "cantidad de registros procesados: $cantidad\n\n";
print  "fin de proceso\n";
