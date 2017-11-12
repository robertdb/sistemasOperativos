#!/usr/bin/perl

use lib ".";
use Filtros;
use Tron;

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

while($opcionMenuPrincipal!=0) {
    print "Opciones de input:\n\n";
    print "1- Seleccionar un archivo específico\n";
    print "2. Varios archivos\n";
    print "3. Todos los archivos plásticos emitidos\n";
    print "4. Todos los archivos plásticos distribución\n";
    print "5. Ayuda\n";
    print "0. SALIR\n\n";

    $file_option = <STDIN>;

    my @files_input = ();
    if($file_option == 1) {
        $cantidad =0;
        while ($cantidad == 0) {
            print "Ingrese un nombre de archivo\n";
            print "    (eg: plasticos_emitidos_000.txt, ",
                  "plasticos_distribucion_sec001.txt)\n";
            print "0 para salir y volver al menu anterior\n";

            $archivoABuscar = <STDIN>;
            chomp($archivoABuscar);

            # Salgo si input es 0
            if ( $archivoABuscar eq 0 ) {
                $cantidad = 1;
                $opcion_listado = 0;
                next
            }

            # Busco el archivo en validados y reportes
            if (-f "$DIR_VALIDADOS/$archivoABuscar") {
                push @files_input, "$DIR_VALIDADOS/$archivoABuscar";
            }
            if (-f "$DIR_REPORTES/$archivoABuscar") {
                push @files_input, "$DIR_REPORTES/$archivoABuscar";
            }

            $cantidad = @files_input;

            # Si no lo encontro pide de nuevo
            if ($cantidad == 1){
                $opcion_listado =9;
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
                # Si no lo encontro pide de nuevo
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
    my $file_output_name = "";

    while ($opcion_listado != 0) {

        print "=== selecciones la opción de listado:\n\n";

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

                print "Formato para todos los registros: *\n";
                print "Formato de filtro por entidad: exxx,exxx-xxx\n";
                print "Formato de filtro por cuenta: cxxx...\n";
                print "Formato de filtro por condicion de distribución: exxx,exxx-xxx\n";
                print "Formato de filtro por estado de cuenta: Cxxx-xxx-xxx-...\n";
                print "Formato de filtro por fuente: fxxxxxx\n";
                print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
                print "0 - volver al menu anterior\n\n";

                $stringJia = Filtros::validar();
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

                $stringJia = Filtros::validar();
                if ($stringJia eq "0"){
                    $opcion_filtrado = 0;
                }

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

                $stringJia = Filtros::validar();
                if ($stringJia eq "0"){
                    $opcion_filtrado = 0;
                }

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

            print "Formato para todos los registros: *\n";
            print "Formato de filtro por entidad: exxx,exxx-xxx\n";
            print "Formato de filtro por cuenta: cxxx...\n\n";
            print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
            print "0 - volver al menu anterior\n\n";

            $stringJia = Filtros::validar();
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

                print "=== Ingrese los filtros de búsqueda:\n\n";
                print "Formato para todos los registros: *\n";
                print "Formato de filtro por tarjeta: txxx...\n\n";
                print "Ingrese los filtros separados por coma: fitro1,filtro2\n";
                print "0 - volver al menu anterior\n\n";

                $stringJia = Filtros::validar();
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
    my %filters = %{shift @_};
    my @files = @{ shift @_};

    my $file_output_name = shift @_;

    my $cantidad = 0;

    foreach $file (@files){
        open(ENTRADA, "$file") || die "ERROR no se pudo abrir el archivo";

        my $secuence;
        if ( $file =~ /\_.*\_(.*?)\./ ) {
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
            Tron::TRACE("procesando linea: ", substr($row, 0, 50));

            if (!Filtros::filtrarEntidades($row,\%filters)) {
                Tron::TRACE("entidades rechaza");
                next;
            }

            if (!Filtros::filtrarFuentes ($row,\%filters)) {
                Tron::TRACE("fuente rechaza");
                next;
            }

            if (!Filtros::filtrarCondicionesDeDistribucion($row,\%filters)) {
                Tron::TRACE("cond de distribucion rechaza");
                next;
            }

            if (!Filtros::filtrarTarjetas($row,\%filters)) {
                Tron::TRACE("tarjeta rechaza");
                next;
            }

            if (!Filtros::filtrarCuentas ($row,\%filters)) {
                Tron::TRACE("cuenta rechaza");
                next;
            }

            if (!Filtros::filtrarEstadoDeTarjeta ($row,\%filters)) {
                next;
            }


            if (!Filtros::filtrarEstadoDeCuenta ($row,\%filters)) {
                next;
            }


            Tron::TRACE("registro correcto:$row");
            print SALIDA $row;

            $cantidad++;
        }

        close(ENTRADA);
        close(SALIDA);
        print "archivo procesado: $file\n";
        print "cantidad de registros procesados: $cantidad\n\n";
    }
}
