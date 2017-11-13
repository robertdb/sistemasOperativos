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
            print "Ingrese uno o mas nombres de archivos, separados por coma\n",
                  "    (eg: plasticos_emitidos_000.txt,",
                  "plasticos_distribucion_sec001.txt\n";
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
        print "Los nombres de archivos deben ingresarse completos, con extencion incluida\n",
              "    eg: plasticos_emitidos_000.txt\n",
              "\n",
              "Sintaxis de los filtros, en Forma Backus-Naur Extendida (EBNF)\n",
              "    entidades = \"e\", codigo, [ \"-\", codigo ];\n",
              "    codigo = 3 * numero;\n",
              "    numero = \"0\" | \"1\" | \"2\" | \"3\" | \"4\" | \"5\" | \"6\" | \"7\" | \"8\" | \"9\";\n",
              "\n",
              "    fuentes = \"f\", codigo;\n",
              "    codigo = 3 * numero;\n",
              "    numero = \"0\" | \"1\" | \"2\" | \"3\" | \"4\" | \"5\" | \"6\" | \"7\" | \"8\" | \"9\";\n",
              "\n",
              "    condiciones_de_distribucion = \"d\", condicion;\n",
              "    condicion = \"NO\" | \"URG\" | \"RETENER\" | \"ESTANDAR\";\n",
              "\n",
              "    tarjetas = \"t\", sub;\n",
              "    sub = ? cadena de caracteres a buscar en documento tarjeta ?;\n",
              "\n",
              "    estado_tarjeta = \"T\", lista_de_estados;\n",
              "    lista_de_estados = { denunciada | bloqueada | vencida };\n",
              "    denunciada = [ \"d\" | \"D\" ];\n",
              "    bloqueada = [ \"b\" | \"B\" ];\n",
              "    vencida = [ \"v\" | \"V\" ];\n",
              "\n",
              "    cuentas = \"c\", sub;\n",
              "    sub = ? cadena de caracteres a buscar en documento cuenta ?;\n",
              "\n",
              "    estado_cuenta = \"C\", lista_de_estados;\n",
              "    lista_de_estados = estado, { \"-\", lista_de_estados }\n",
              "    estado = \"ACT\" | \"BAJA\" | \"CTX\" | \"JUD\";\n",
              "\n";
    }
    my $file_output_name = "";

    while ($opcion_listado != 0) {

        print "=== elija por que criterio listar:\n\n";

        print "1- Por estado de cuenta\n";
        print "2. Por estado de tarjeta\n";
        print "3. Por condición de distribución\n";
        print "4. Por numero de cuenta\n";
        print "5. Por numero de tarjeta\n\n";

        print "0. Volver al menu anterior\n\n";

        $opcion_listado = <STDIN>;
        chomp $opcion_listado;

        $opcion_filtrado = -1;

        if($opcion_listado == 1){
            while ($opcion_filtrado != 0){
                print "Ingrese C seguido de uno o mas de ACT BAJA CTX JUD\n";
                print "    separados por -\n";
                print "Ingrese 0 para volver al menu anterior\n\n";

                # Obtener filtros, parsearlos, filtrar e imprimir
                $stringJia = Filtros::validar();
                if ($stringJia eq "0") {
                    $opcion_filtrado = 0;
                } else {
                    %filtros=();
                    if ($stringJia ne "*") {
                        @arr_filtros = split(',', $stringJia);

                        # Parsear filtros (separar "e013" en "e", y "013")
                        foreach my $x (@arr_filtros) {
                            $key = substr $x, 0, 1;
                            $value = substr $x, 1, ;
                            $filtros{$key} = $value;
                        }
                    }
                    search_by_filters(\%filtros, \@files_input, "listado_cuentas_");
                }
            }
        }

        if($opcion_listado == 2){
            while ($opcion_filtrado != 0){
                print "Ingrese T seguido de uno o mas de\n";
                print "    d, b, o v para denuncidada, bloqueada, o vencida\n";
                print "    D, B, o V para su negacion\n";
                print "Ingrese 0 para volver al menu anterior\n\n";

                # Obtener filtros, parsearlos, filtrar e imprimir
                $stringJia = Filtros::validar();
                if ($stringJia eq "0") {
                    $opcion_filtrado = 0;
                } else {
                    %filtros=();
                    if ($stringJia ne "*") {
                        @arr_filtros = split(',', $stringJia);

                        # Parsear filtros (separar "e013" en "e", y "013")
                        foreach my $x (@arr_filtros) {
                            $key = substr $x, 0, 1;
                            $value = substr $x, 1, ;
                            $filtros{$key} = $value;
                        }
                    }
                    search_by_filters(\%filtros, \@files_input, "listado_cuentas_");
                }
            }
        }

        if($opcion_listado == 3){
            while ($opcion_filtrado != 0){
                print "Ingrese d seguido de uno de NO, URG, RETENER, o ESTANDAR\n";
                print "Ingrese 0 para volver al menu anterior\n\n";

                # Obtener filtros, parsearlos, filtrar e imprimir
                $stringJia = Filtros::validar();
                if ($stringJia eq "0") {
                    $opcion_filtrado = 0;
                } else {
                    %filtros=();
                    if ($stringJia ne "*") {
                        @arr_filtros = split(',', $stringJia);

                        # Parsear filtros (separar "e013" en "e", y "013")
                        foreach my $x (@arr_filtros) {
                            $key = substr $x, 0, 1;
                            $value = substr $x, 1, ;
                            $filtros{$key} = $value;
                        }
                    }
                    search_by_filters(\%filtros, \@files_input, "listado_cuentas_");
                }
            }
        }

        if($opcion_listado == 4){
            while ($opcion_filtrado != 0){
                print "Ingrese c seguido del documento asociado a la cuenta\n";
                print "Ingrese 0 para volver al menu anterior\n\n";

                # Obtener filtros, parsearlos, filtrar e imprimir
                $stringJia = Filtros::validar();
                if ($stringJia eq "0") {
                    $opcion_filtrado = 0;
                } else {
                    %filtros=();
                    if ($stringJia ne "*") {
                        @arr_filtros = split(',', $stringJia);

                        # Parsear filtros (separar "e013" en "e", y "013")
                        foreach my $x (@arr_filtros) {
                            $key = substr $x, 0, 1;
                            $value = substr $x, 1, ;
                            $filtros{$key} = $value;
                        }
                    }
                    search_by_filters(\%filtros, \@files_input, "listado_cuentas_");
                }
            }
        }

        if($opcion_listado == 5){
            while ($opcion_filtrado != 0){
                print "Ingrese t seguido del documento asociado a la tarjeta\n";
                print "Ingrese 0 para volver al menu anterior\n\n";

                # Obtener filtros, parsearlos, filtrar e imprimir
                $stringJia = Filtros::validar();
                if ($stringJia eq "0") {
                    $opcion_filtrado = 0;
                } else {
                    %filtros=();
                    if ($stringJia ne "*") {
                        @arr_filtros = split(',', $stringJia);

                        # Parsear filtros (separar "e013" en "e", y "013")
                        foreach my $x (@arr_filtros) {
                            $key = substr $x, 0, 1;
                            $value = substr $x, 1, ;
                            $filtros{$key} = $value;
                        }
                    }
                    search_by_filters(\%filtros, \@files_input, "listado_cuentas_");
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

    print "registros encontrados:\n";
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
        open(my $SALIDA, '>', $file_output) or die "ERROR no se pudo abrir el archivo '$file_output' $!";


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


            Tron::TRACE("registro correcto:$row\n");

            # Imprimir por pantalla el numero de cuenta
            {
                my @cosa = split(/;/, $row);
                print "    ", $cosa[1], "\n";
            }

            print $SALIDA $row;

            $cantidad++;
        }

        close(ENTRADA);
        close($SALIDA);
        print "archivo procesado: $file\n";
        print "cantidad de registros procesados: $cantidad\n\n";
    }
}
