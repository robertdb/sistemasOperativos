#!/usr/bin/perl

$DIR_VALIDADOS = "./validados";
$DIR_REPORTES = "./reportes";


$DIR_OUTPUT = "./reportes";
$FILE_OUTPUT_CUENTAS = "listados_cuentas_";
$FILE_OUTPUT_TARJETAS = "listados_tarjetas_";
$FILE_OUTPUT_COND_DISTR = "listados_cond_distr_";

system("clear");

print "=====    LISTADOR: Modalidad Manual    =====\n\n";

my $file_option = 9;
my $dir_file_input;

#while($file_option!=0){
	print "Opciones de input:\n\n";
	print "1- Seleccionar un archivo específico\n";
	print "2. Varios archivos\n";
	print "3. Todos los archivos plásticos emitidos\n";
	print "4. Todos los archivos plásticos distribución\n";
	print "5. Ayuda\n";
	print "0. SALIR\n\n";

	$file_option = <STDIN>;

	my @files_input = ();
	if($file_option == 3){
		opendir(DIR, $DIR_VALIDADOS) or die $!;
		while (my $file = readdir(DIR)) {
			next unless (-f "$DIR_VALIDADOS/$file");
			push @files_input, "$DIR_VALIDADOS/$file";
			
		}
		#print "files_input: @files_input\n\n";
	}

	if($file_option == 4){
    	opendir(DIR, $DIR_REPORTES) or die $!;
		while (my $file = readdir(DIR)) {
			next unless (-f "$DIR_REPORTES/$file");
			if($file =~ m/plasticos_distribucion/) {
				push @files_input, "$DIR_REPORTES/$file";
			}
		}
		#print "files_input: @files_input\n\n";
	}

my $opcion_listado=9;
my $file_output_name = "";

while($opcion_listado!=0){
	system("clear");
	print"=== selecciones la opción de listado:\n\n";

	print "1- Listado de cuentas\n";
	print "2. Listados de tarjetas\n";
	print "3. Listado de condición de distribución\n";
	print "4. Listado de la situación de una cuenta en particular\n";
	print "5. Listado de la situación de una tarjeta en particular\n\n";

	print "0. SALIR\n\n";

	$opcion_listado = <STDIN>;
	chomp $opcion_listado;

	if($opcion_listado == 1){
		while ($opcion_listado != 0){
			system("clear");
			print "=== Ingrese los filtros de búsqueda:\n\n";
			print "Opciones de filtros : ACTIVAS, BAJA, CTX o JUD\n\n";
			print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
			print "0 - volver al menu anterior\n\n";

			print "Filtros: ";

			$opcion_listado = <STDIN>;
			chomp $opcion_listado;

			if($opcion_listado ne "0"){
				$opcion_listado = uc($opcion_listado);
				my @filters = split(/\,/, $opcion_listado);

				print "# inicio de proceso...\n\n";
				search_by_filters(\@filters, \@files_input, "listado_cuentas_");
				print  "# fin de proceso\n\n";
			}
			
		}
	}

	if($opcion_listado == 2){
		while ($opcion_listado != 0){
			system("clear");
			print "=== Ingrese los filtros de búsqueda:\n\n";
			print "Opciones de filtros : BLOQUEADAS, DENUNCIADAS, VENCIDAS\n\n";
			print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
			print "0 - volver al menu anterior\n\n";

			print "Filtros: ";

			$opcion_listado = <STDIN>;
			chomp $opcion_listado;

			if($opcion_listado ne "0"){
				$opcion_listado = uc($opcion_listado);
				my @filters = split(/\,/, $opcion_listado);
				print "# inicio de proceso...\n\n";
				search_by_filters(\@filters, \@files_input, "listado_tarjetas_");
				print  "# fin de proceso\n\n";
			}
			
		}
	}
}

# genera los archivos de reportes según los archivos 
# y filtros pasados por parametro
sub search_by_filters {
 	my $cantidad = 0;

 	# obtengo las referencias
 	my ($filters_ref, $files_ref, $file_output_name) = @_;

 	# obtengo los arrays
 	my @filters = @{ $filters_ref };
 	my @files = @{ $files_ref };

	#print "### filtros: @filters\n\n";
	#print "### files_input: @files\n\n";

	foreach $file (@files){
		#print "file:  $file\n\n";
		open(ENTRADA, "$file") || die "ERROR no se pudo abrir el archivo";

		my $secuence;
		if ( $file =~ /\_.*\_(.*?)\./ )
		{
		    $secuence = $1;
		}
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
		$year += 1900;
		$mon++;

		my $SEP = "_";
		my $fecha_hora = "$year$mon$mday$hour$min$sec$SEP";

		# archivo unico
		$file_output = "$DIR_OUTPUT/$file_output_name$fecha_hora$secuence.txt";
		open($SALIDA, '>', $file_output) or die "ERROR no se pudo abrir el archivo '$file_output' $!";

		while ($row=<ENTRADA>){
			@list = split( /(;)/, $row);
			if ( grep( /^$list[4]$/, @filters ) ) {
  				print $SALIDA join('', @list);
				$cantidad++;
			}
		}

		close(ENTRADA);
		close(SALIDA);
		print "archivo procesado: $file\n";
		print "cantidad de registros procesados: $cantidad\n\n";
	}

	closedir(DIR);
}