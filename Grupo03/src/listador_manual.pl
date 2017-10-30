#!/usr/bin/perl


#funcions
### FILTROS
# Todas las subrutinas
#   $registro (string) valor del registro como se encuentra en el
#   \%filtros (hash) conjunto de filtros en los que
#
# Todas las funciones evaluan a verdadero si y solo si el
# cumple con el filtro y debe ser aceptado.

# Usa $filtros{"e"}, espera uno de los siguientes formatos:
# undef: aceptar
# ddd: aceptar sii nro_entidad ==
# aaa-bbb: aceptar sii aaa <= nro_entidad <=
sub filtrarEntidades {
    my @reg = split(/;/, shift @_);
    my $entidad = @reg[22];

    my %filtros = %{shift @_};

    TRACE("filtrando por entidad ", $entidad);

    if (! exists $filtros{"e"}) {
        TRACE("registro aceptado: no hay filtro");
        TRACE();
        return 1;
    }

    if (!( $filtros{"e"} =~ /^(...)(-(...))?$/ )) {
        TRACE("registro rechazado: filtro mal formado ", $filtros{"e"});
        TRACE();
        return 0;
    }

    if ($entidad < $1) {
        TRACE("registro rechazado: ", $entidad, "<", $1);
        TRACE();
        return 0;
    }
    if ($3 != undef && $3 < $entidad) {
        TRACE("registro rechazado: ", $entidad, ">", $3);
        TRACE();
        return 0;
    }
    elsif ($3 == undef && $entidad != $1) {
        TRACE("registro rechazado: ", $entidad, "!=", $1);
        TRACE();
        return 0;
    }

    TRACE("registro aceptado");
    TRACE();
    return 1;
}

# Usa $filtros{"f"}, espera uno de los siguientes formatos:
# undef: aceptar
# ddd: aceptar sii fuente es de la forma xxxxxxx_ddd.
sub filtrarFuentes {
    my @reg = split(/;/, shift @_);
    my $fuente = @reg[0];

    my %filtros = %{shift @_};

    TRACE("filtrando por fuente ", $fuente);

    if (! exists $filtros{"f"}) {
        TRACE("registro aceptado: no hay filtro");
        TRACE();
        return 1;
    }

    $fuente =~ /.*_(\d\d\d).txt/;
    if ($1 == $filtros{"f"}) {
        TRACE("registro aceptado");
        TRACE();
        return 1;
    }

    TRACE("registro rechazado: ", $fuente, "!=", $1);
    TRACE();
    return 0;
}

# Usa $filtros{"d"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii condicion =~ /re/
sub filtrarCondicionesDeDistribucion {
    my @reg = split(/;/, shift @_);
    my $condicion = @reg[6];

    my %filtros = %{shift @_};

    TRACE("filtrando por condicion de distribucion ", $condicion);

    if (! exists $filtros{"d"}) {
        TRACE("registro aceptado: no hay filtro");
        TRACE();
        return 1;
    }


    if ($condicion =~ /$filtros{"d"}/) {
        TRACE("registro aceptado");
        TRACE();
        return 1;
    }

    TRACE("registro rechazado: ", $condicion, " no matchea ", $filtros{"d"});
    TRACE();
    return 0;
}

# Usa $filtros{"t"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii tarjeta =~ /re/
sub filtrarTarjetas {
    my @reg = split(/;/, shift @_);
    my $tarjeta = @reg[9];

    my %filtros = %{shift @_};

    TRACE("filtrando por tarjeta ", $tarjeta);

    if (! exists $filtros{"t"}) {
        TRACE("registro aceptado: no hay filtro");
        TRACE();
        return 1;
    }

    if ($tarjeta =~ /$filtros{"t"}/) {
        TRACE("registro aceptado");
        TRACE();
        return 1;
    }

    TRACE("registro rechazado: ", $tarjeta, " no matchea ", $filtros{"t"});
    TRACE();
    return 0;
}

# Usa $filtros{"c"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii cuenta =~ /re/
sub filtrarCuentas {
    my @reg = split(/;/, shift @_);
    my $cuenta = @reg[17];

    my %filtros = %{shift @_};

    TRACE("filtrando por cuenta ", $cuenta);

    if (! exists $filtros{"c"}) {
        TRACE("registro aceptado: no hay filtro");
        TRACE();
        return 1;
    }

    if ($cuenta =~ /$filtros{"c"}/) {
        TRACE("registro aceptado");
        TRACE();
        return 1;
    }

    TRACE("registro rechazado: ", $cuenta, " no matchea ", $filtros{"c"});
    TRACE();
    return 0;
}

# Usa $filtros{"T"}, espera uno de los siguientes formatos:
# undef: aceptar todo
# lista_de_estados: aceptar sii el estado de la tarjeta
#   corresponde a la lista solicitada. Un estado en minuscula
#   significa que el campo debe estar seteado (eg: "d" significa que
#   la tarjeta debe estar denunciada) Un estado en mayuscula
#   significa que el campo de no estar seteado (eg: "D" significa que
#   la tarjeta no debe estar denunciada)
#
#   En caso en que un estado (o dos estados contradictorios) aparezca
#   mas de una vez, la primera instancia toma precedencia
#   (eg: en "dBvD" la tarjeta debe estar denunciada para corresponder
#   al filtro)
#
# EBNF
#   lista_de_estados = { denunciada | bloqueada | vencida }
#   denunciada = [ "d" | "D" ]
#   bloqueada = [ "b" | "B" ]
#   vencida = [ "v" | "V" ]
sub filtrarEstadoDeTarjeta {
    my @reg = split(/;/, shift @_);
    my @estado = @reg[3..5];

    my %filtros = %{shift @_};

    TRACE("filtrando por estado de tarjeta ", @estado);

    if (! exists $filtros{"T"}) {
        TRACE("registro aceptado: no hay filtro");
        return 1;
    }

    my $v = @estado[0];
    my $d = @estado[1];
    my $b = @estado[2];

    my $xv = "*";
    my $xd = "*";
    my $xb = "*";

    my $filtro = $filtros{"T"};
    my $temp;
    while ( ($temp = chop($filtro)) ne "" ) {
        if ($temp eq "v") { $xv = 1; }
        elsif ($temp eq "V") { $xv = 0; }
        elsif ($temp eq "d") { $xd = 1; }
        elsif ($temp eq "D") { $xd = 0; }
        elsif ($temp eq "b") { $xb = 1; }
        elsif ($temp eq "B") { $xb = 0; }
    }
    TRACE("filtro: ", $xv, $xd, $xb);

    if ($xv != "*" and $xv ne $v) {
        TRACE("registro rechazado: vencimiento");
        return 0;
    }
    if ($xd != "*" and $xd ne $d) {
        TRACE("registro rechazado: denuncia");
        return 0;
    }
    if ($xb != "*" and $xb ne $b) {
        TRACE("registro rechazado: bloqueo");
        return 0;
    }

    TRACE("registro aceptado");
    return 1;
}

# Usa $filtros{"C"}, espera uno de los siguientes formatos:
# undef: aceptar todo
# lista_de_estados: aceptar sii el estado de la tarjeta es uno de
#   los estados solicitados
#
#   Los estados
#
# EBNF
#   lista_de_estados = estado { "-" lista_de_estados }
#
# estado es un prefijo case-insensitive (eg: act, a, ACTIVA, y Act, todas
#   matchean ACTIVA)
sub filtrarEstadoDeCuenta {
    my @reg = split(/;/, shift @_);
    my $estado = @reg[2];

    my %filtros = %{shift @_};

    TRACE("filtrando por estado de cuenta ", $estado);

    if (! exists $filtros{"C"}) {
        TRACE("registro aceptado: no hay filtro");
        TRACE();
        return 1;
    }

    TRACE("filtro: ", $filtros{"C"});
    my @f = split(/-/, $filtros{"C"});
    foreach $e (@f) {
        $e = uc($e);
        $estado = uc($estado);
        if ($e eq substr($estado, 0, length($e))) {
            TRACE("registro aceptado");
            TRACE();
            return 1;
        }
    }

    TRACE("registro rechazado");
    TRACE();
    return 0;
}

### FILTROS

### VALIDAR FILTROS
sub validar {
    $filtro = <STDIN>;
    chomp($filtro);

    TRACE("Filtro es ", $filtro);
#    if ($filtro eq "0") { return $filtro; }
#    if ($filtro eq "*") { return $filtro; }

    $incorrecto = 1;
    while ( $incorrecto == 1 ) {
      if ($filtro eq "0") { return $filtro; }
      if ($filtro eq "*") { return $filtro; }
        TRACE("entrando al loop");

        @array=split(',',$filtro);
        $hayIncorrecto = 0;
        foreach $cosa (@array) {
            TRACE("foreach: ", $cosa);
            if ( $cosa =~ /^[c,t,d,e,f,T].*/) {
            } else {
                $hayIncorrecto = 1;
                last;
            }
        }

        if ($hayIncorrecto eq 1) {
            print "Error: modo de filtro invalido, reingrese\n";
            $filtro = <STDIN>;
            chomp($filtro);
        } else {
            $incorrecto = 0;
        }
    }
    return $filtro;
}

### VALIDAR FILTROS


$TRON = 0;


$DIR_VALIDADOS = $ENV{"VALIDADOS"};
$DIR_REPORTES = $ENV{"REPORTES"};

$FILE_OUTPUT_CUENTAS = "listados_cuentas_";
$FILE_OUTPUT_TARJETAS = "listados_tarjetas_";
$FILE_OUTPUT_COND_DISTR = "listados_cond_distr_";



print "=====    LISTADOR: Modalidad Manual    =====\n\n";

my $file_option = 9;
my $dir_file_input;
# VOLVER AL WHILE
$opcionMenuPrincipal = 9;

while($opcionMenuPrincipal!=0){
	print "Opciones de input:\n\n";
	print "1- Seleccionar un archivo específico\n";
	print "2. Varios archivos\n";
	print "3. Todos los archivos plásticos emitidos\n";
	print "4. Todos los archivos plásticos distribución\n";
	print "5. Ayuda\n";
	print "0. SALIR\n\n";

	$file_option = <STDIN>;

	my @files_input = ();
    if($file_option == 1){
      $cantidad =0;
      while ($cantidad == 0){
        print "Ingrese un archivo de plasticos emitidos o de distribucion\n";
        print "0 para salir y volver al menu anterior\n";

        $archivoABuscar = <STDIN>;
        chomp($archivoABuscar);
        if ( $archivoABuscar eq 0 ){
          $cantidad = 1;
          $opcion_listado = 0;
        }
        else {
  # Busco en validados
        opendir(DIR, $DIR_VALIDADOS) or die $!;
  		   @files = readdir(DIR);
  		  closedir(DIR);
          foreach my $file (@files) {

      		next unless (-f "$DIR_VALIDADOS/$file");
    #                print "$file\n";
          if ( $archivoABuscar eq $file){
      		  push @files_input, "$DIR_VALIDADOS/$file";
            last;
          }
      	}
        opendir(DIR, $DIR_REPORTES) or die $!;
        @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
    		    next unless (-f "$DIR_REPORTES/$file");
  #          print "$file\n";
            if ( $archivoABuscar eq $file){
    		        push @files_input, "$DIR_REPORTES/$file";
                last;
        }
     }
    $cantidad = @files_input;
  #  print "cantidad $cantidad\n";
  #Si no lo encontro pide de nuevo
   if ($cantidad == 1){
     $opcion_listado =9;
    }
   }
   }
  }


if($file_option == 2){
  $cantidad =1;
  $cantidadABuscar =0;
  while ($cantidad != $cantidadABuscar) {
    print "Ingrese nombre de archivos de plasticos emitidos o de distribucion\n";
    print "Separados por coma, ej: archivo1.txt,archivo2.txt\n";
    print "0 para salir y volver al menu anterior\n";

    $archivoABuscar = <STDIN>;
    chomp($archivoABuscar);
    if ( $archivoABuscar eq 0 ){
      $cantidad = $cantidadABuscar;
      $opcion_listado = 0;
    }
    else {
      @archivos = split(',',$archivoABuscar);

# Busco en validados
    opendir(DIR, $DIR_VALIDADOS) or die $!;
     @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
    next unless (-f "$DIR_VALIDADOS/$file");
    foreach $archivoABuscar(@archivos){
    if ( $archivoABuscar eq $file){
      push @files_input, "$DIR_VALIDADOS/$file";
      last;
    }
  }
  }
    opendir(DIR, $DIR_REPORTES) or die $!;
    @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
        next unless (-f "$DIR_REPORTES/$file");
    foreach $archivoABuscar(@archivos){
        if ( $archivoABuscar eq $file){
            push @files_input, "$DIR_REPORTES/$file";
            last;
    }
  }
 }
    $cantidad = @files_input;
    $cantidadABuscar = @archivos;
#    print "cantidad $cantidad\n";
#    print "cantidad a buscar $cantidadABuscar\n";
#Si no lo encontro pide de nuevo
    if ($cantidad == $cantidadABuscar){
      $opcion_listado =9;
    }
  }
  }
}




	if($file_option == 3){
		opendir(DIR, $DIR_VALIDADOS) or die $!;
		@files = readdir(DIR);
		closedir(DIR);

	foreach my $file (@files) {
		next unless (-f "$DIR_VALIDADOS/$file");
		push @files_input, "$DIR_VALIDADOS/$file";
	}
   $opcion_listado = 9;
		#print "files_input: @files_input\n\n";
	}

	if($file_option == 4){
  	opendir(DIR, $DIR_REPORTES) or die $!;
		@files = readdir(DIR);
		closedir(DIR);
		foreach my $file (@files) {
			next unless (-f "$DIR_REPORTES/$file");
			if($file =~ m/plasticos_distribucion/) {
				push @files_input, "$DIR_REPORTES/$file";
			}
		}
   $opcion_listado = 9;
		#print "files_input: @files_input\n\n";
	}
  if ($file_option == 0){
    $opcion_listado =0 ;
    $opcionMenuPrincipal = 0;
    print "Fin del programa\n";
  }
  if ($file_option == 5){
    $opcion_listado =0 ;
    print "-----------AYUDA-----------\n\n";
    print "Buscador de listas por filtros de campos\n";
    print "Seleccione opciones del menu y sigua las instrucciones\n";
    print "Para los archivos a buscar, se pasan el nombre completo con .txt\n";
    print "Para los filtros: se separan con ','\n";
  }
#my $opcion_listado=9;
my $file_output_name = "";

while($opcion_listado!=0){

	print"=== selecciones la opción de listado:\n\n";

	print "1- Listado de cuentas\n";
	print "2. Listados de tarjetas\n";
	print "3. Listado de condición de distribución\n";
	print "4. Listado de la situación de una cuenta en particular\n";
	print "5. Listado de la situación de una tarjeta en particular\n\n";

	print "0. Volver al menu anterior\n\n";

	$opcion_listado = <STDIN>;
	chomp $opcion_listado;

	$opcion_filtrado = -1;

	if($opcion_listado == 1){
		while ($opcion_filtrado != 0){

			print "=== Ingrese los filtros de búsqueda:\n\n";

			#print "Opciones de filtros : ACTIVAS, BAJA, CTX o JUD\n\n";

			print "Formato para todos los registros: *\n";
			print "Formato de filtro por entidad: exxx,exxx-xxx\n";
			print "Formato de filtro por cuenta: cxxx...\n";
			print "Formato de filtro por condicion de distribución: exxx,exxx-xxx\n";
			print "Formato de filtro por estado de cuenta: Cxxx-xxx-xxx-...\n";
			print "Formato de filtro por fuente: fxxxxxx\n";
			print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
			print "0 - volver al menu anterior\n\n";

			# validacion de jia
			$stringJia = validar();
			#  YA ESTAN VALIDADOS LOS FILTROS
      if ($stringJia eq "0"){
        $opcion_filtrado = 0;
      }
			if($stringJia ne "0"){
				%filtros=();
        print "Los filtros son de $stringJia\n";
				if ($stringJia ne "*") {

					@arr_filtros = split(',', $stringJia);
					foreach my $x (@arr_filtros) {
						$key = substr $x, 0, 1;
						$value = substr $x, 1, ;
						print "clave:$key valor:$value\n";
						$filtros{$key} = $value;
					}
				}
#        print "Filtrado por $stringJia\n";
				print "# inicio de proceso...\n\n";
				search_by_filters(\%filtros, \@files_input, "listado_cuentas_");
				print  "# fin de proceso\n\n";
			}

		}
	}

	if($opcion_listado == 2){
		while ($opcion_filtrado != 0){

			print "=== Ingrese los filtros de búsqueda:\n\n";
			print "Formato para todos los registros: *\n";
			print "Formato de filtro por entidad: exxx,exxx-xxx\n";
			print "Formato de filtro por tarjeta: txxx...\n";
			print "Formato de filtro por condicion de distribución: exxx,exxx-xxx\n";
			print "Formato de filtro por estado de tarjeta: Txxx-xxx-xxx-...\n";
			print "Formato de filtro por fuente: fxxxxxx\n";
			print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
			print "0 - volver al menu anterior\n\n";


			# validacion de jia
			$stringJia = validar();
      if ($stringJia eq "0"){
        $opcion_filtrado = 0;
      }
			#  YA ESTAN VALIDADOS LOS FILTROS

			if($stringJia ne "0"){

				%filtros=();
        print "Los filtros son de $stringJia\n";
				if ($stringJia != "*") {
					@arr_filtros = split(',', $stringJia);
					foreach my $x (@arr_filtros) {
						$key = substr $x, 0, 1;
						$value = substr $x, 1, ;
						$filtros{$key} = $value;
					}
				}

				print "# inicio de proceso...\n\n";
				search_by_filters(\%filters, \@files_input, "listado_tarjetas_");
				print  "# fin de proceso\n\n";
			}

		}
	}

	if($opcion_listado == 3){
		while ($opcion_filtrado != 0){

			print "=== Ingrese los filtros de búsqueda:\n\n";
			print "Formato para todos los registros: *\n";
			print "Formato de filtro por condicion de distribución: dxxx\n";
			print "Formato de filtro por estado de tarjeta: Txxx-xxx-xxx-...\n";
			print "Formato de filtro por estado de cuenta: Cxxx-xxx-xxx-...\n\n";
			print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
			print "0 - volver al menu anterior\n\n";


			# validacion de jia
			$stringJia = validar();
      if ($stringJia eq "0"){
        $opcion_filtrado = 0;
      }
			#  YA ESTAN VALIDADOS LOS FILTROS

			if($stringJia ne "0"){

				%filtros=();
        print "Los filtros son de $stringJia\n";
				if ($stringJia != "*") {
					@arr_filtros = split(',', $stringJia);
					foreach my $x (@arr_filtros) {
						$key = substr $x, 0, 1;
						$value = substr $x, 1, ;
						$filtros{$key} = $value;
					}
				}

				print "# inicio de proceso...\n\n";
				search_by_filters(\%filters, \@files_input, "listado_condist_");
				print  "# fin de proceso\n\n";
			}

		}
	}

	if($opcion_listado == 4){
		print "=== Ingrese los filtros de búsqueda:\n\n";

		#print "Opciones de filtros : ACTIVAS, BAJA, CTX o JUD\n\n";

		print "Formato para todos los registros: *\n";
		print "Formato de filtro por entidad: exxx,exxx-xxx\n";
		print "Formato de filtro por cuenta: cxxx...\n\n";
		print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
		print "0 - volver al menu anterior\n\n";

		# validacion de jia
		$stringJia = validar();
    if ($stringJia eq "0"){
      $opcion_filtrado = 0;
    }
		#  YA ESTAN VALIDADOS LOS FILTROS

		if($stringJia ne "0"){

			%filtros=();
        print "Los filtros son de $stringJia\n";
			if ($stringJia ne "*") {

				@arr_filtros = split(',', $stringJia);
				foreach my $x (@arr_filtros) {
					$key = substr $x, 0, 1;
					$value = substr $x, 1, ;
#					print "clave:$key valor:$value\n";
					$filtros{$key} = $value;
				}
			}

			print "# inicio de proceso...\n\n";
			search_by_filters(\%filtros, \@files_input,
                    "listado_cuenta_particular_");
			print  "# fin de proceso\n\n";
		}
	}

	if($opcion_listado == 5){

		while ($opcion_filtrado != 0){

			print "=== Ingrese los filtros de búsqueda:\n\n";

			#print "Opciones de filtros : ACTIVAS, BAJA, CTX o JUD\n\n";

			print "=== Ingrese los filtros de búsqueda:\n\n";
			print "Formato para todos los registros: *\n";
			print "Formato de filtro por tarjeta: txxx...\n\n";
			print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
			print "0 - volver al menu anterior\n\n";

			# validacion de jia
			$stringJia = validar();
      if ($stringJia eq "0"){
        $opcion_filtrado = 0;
      }
			#  YA ESTAN VALIDADOS LOS FILTROS

			if($stringJia ne "0"){

				%filtros=();
        print "Los filtros son de $stringJia\n";
				if ($stringJia ne "*") {

					@arr_filtros = split(',', $stringJia);
					foreach my $x (@arr_filtros) {
						$key = substr $x, 0, 1;
						$value = substr $x, 1, ;
#						print "clave:$key valor:$value\n";
						$filtros{$key} = $value;
					}
				}

				print "# inicio de proceso...\n\n";
				search_by_filters(\%filtros, \@files_input,
                        "listado_tarjeta_particular_");
				print  "# fin de proceso\n\n";
			}

		}
	}
}
}
# genera los archivos de reportes según los archivos
# y filtros pasados por parametro
sub search_by_filters {


 	# obtengo las referencias
 	#my (%filters_ref, $files_ref, $file_output_name) = @_;

	my %filters = %{shift @_};
 	# obtengo los arrays
 	my @files = @{ shift @_};

	my $file_output_name = shift @_;

	my $cantidad = 0;

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
		$file_output = "$DIR_REPORTES/$file_output_name$fecha_hora$secuence.txt";
		open(SALIDA, '>', $file_output) or die "ERROR no se pudo abrir el archivo '$file_output' $!";


		while ($row=<ENTRADA>) {
			TRACE("procesando linea: ", substr($row, 0, 50));

			if (!filtrarEntidades($row,\%filters)) {
				TRACE("entidades rechaza");
				next;
			}

			if (!filtrarFuentes ($row,\%filters)) {
				TRACE("fuente rechaza");
				next;
			}

			if (!filtrarCondicionesDeDistribucion($row,\%filters)) {
				TRACE("cond de distribucion rechaza");
				next;
			}

			if (!filtrarTarjetas($row,\%filters)) {
				TRACE("tarjeta rechaza");
				next;
			}

			if (!filtrarCuentas ($row,\%filters)) {
				TRACE("cuenta rechaza");
				next;
			}

			if (!filtrarEstadoDeTarjeta ($row,\%filters)) {
				next;
			}


			if (!filtrarEstadoDeCuenta ($row,\%filters)) {
				next;
			}


			TRACE("registro correcto:$row");
			print SALIDA $row;


			$cantidad++;

		}

		close(ENTRADA);
		close(SALIDA);
		print "archivo procesado: $file\n";
		print "cantidad de registros procesados: $cantidad\n\n";
	}


}


sub TRACE {
    if (! $TRON) { return; }

    foreach $x (@_) { print $x; }
    print "\n";
}
