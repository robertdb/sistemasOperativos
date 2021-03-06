package Filtros;

use lib ".";
use Tron;

# c,t,d,e,f
# e puede venir con rango
sub validar {
    $filtro = <STDIN>;
    chomp($filtro);

    Tron::TRACE("Filtro es ", $filtro);
    if ($filtro eq "0") { return $filtro; }
    if ($filtro eq "*") { return $filtro; }

    $incorrecto = 1;
    while ( $incorrecto == 1 ) {
        Tron::TRACE("entrando al loop");

        @array=split(',',$filtro);
        $hayIncorrecto = 0;
        foreach $cosa (@array) {
            Tron::TRACE("foreach: ", $cosa);
            if ( $cosa =~ /^[c,t,d,e,f,T,C].*/) {
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

# Todas las subrutinas aceptan los siguientes argumentos
#   $registro (string) linea del archivo a filtrar
#   \%filtros (hash) configuracion a pasar a los filtros
#
# Todas las funciones evaluan a verdadero si y solo si el registro
# cumple con el filtro y debe ser aceptado.

# Usa $filtros{"e"}, espera uno de los siguientes formatos:
# undef: aceptar
# ddd: aceptar sii nro_entidad ==
# aaa-bbb: aceptar sii aaa <= nro_entidad <=
sub filtrarEntidades {
    my @reg = split(/;/, shift @_);
    my $entidad = @reg[22];

    my %filtros = %{shift @_};

    Tron::TRACE("filtrando por entidad ", $entidad);

    if (! exists $filtros{"e"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }

    if (!( $filtros{"e"} =~ /^(...)(-(...))?$/ )) {
        Tron::TRACE("registro rechazado: filtro mal formado ", $filtros{"e"});
        Tron::TRACE();
        return 0;
    }

    if ($entidad < $1) {
        Tron::TRACE("registro rechazado: ", $entidad, "<", $1);
        Tron::TRACE();
        return 0;
    }
    if ($3 != undef && $3 < $entidad) {
        Tron::TRACE("registro rechazado: ", $entidad, ">", $3);
        Tron::TRACE();
        return 0;
    }
    elsif ($3 == undef && $entidad != $1) {
        Tron::TRACE("registro rechazado: ", $entidad, "!=", $1);
        Tron::TRACE();
        return 0;
    }

    Tron::TRACE("registro aceptado");
    Tron::TRACE();
    return 1;
}

# Usa $filtros{"f"}, espera uno de los siguientes formatos:
# undef: aceptar
# ddd: aceptar sii fuente es de la forma xxxxxxx_ddd.
sub filtrarFuentes {
    my @reg = split(/;/, shift @_);
    my $fuente = @reg[0];

    my %filtros = %{shift @_};

    Tron::TRACE("filtrando por fuente ", $fuente);

    if (! exists $filtros{"f"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }

    $fuente =~ /.*_(\d\d\d).txt/;
    if ($1 == $filtros{"f"}) {
        Tron::TRACE("registro aceptado");
        Tron::TRACE();
        return 1;
    }

    Tron::TRACE("registro rechazado: ", $fuente, "!=", $1);
    Tron::TRACE();
    return 0;
}

# Usa $filtros{"d"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii condicion =~ /re/
sub filtrarCondicionesDeDistribucion {
    my @reg = split(/;/, shift @_);
    my $condicion = @reg[6];

    my %filtros = %{shift @_};

    Tron::TRACE("filtrando por condicion de distribucion ", $condicion);

    if (! exists $filtros{"d"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }


    if ($condicion =~ /$filtros{"d"}/) {
        Tron::TRACE("registro aceptado");
        Tron::TRACE();
        return 1;
    }

    Tron::TRACE("registro rechazado: ", $condicion, " no matchea ", $filtros{"d"});
    Tron::TRACE();
    return 0;
}

# Usa $filtros{"t"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii tarjeta =~ /re/
sub filtrarTarjetas {
    my @reg = split(/;/, shift @_);
    my $tarjeta = @reg[9];

    my %filtros = %{shift @_};

    Tron::TRACE("filtrando por tarjeta ", $tarjeta);

    if (! exists $filtros{"t"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }

    if ($tarjeta =~ /$filtros{"t"}/) {
        Tron::TRACE("registro aceptado");
        Tron::TRACE();
        return 1;
    }

    Tron::TRACE("registro rechazado: ", $tarjeta, " no matchea ", $filtros{"t"});
    Tron::TRACE();
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

    my %filtros = %{shift @_};

    Tron::TRACE("filtrando por estado de tarjeta");

    if (! exists $filtros{"T"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }

    # Extraigo el estado actual
    my $d = @reg[4];
    my $b = @reg[5];

    # Decido si la tarjeta esta vencida
    my $fecha = @reg[16];
    $fecha =~ s/(\d*).(\d*).(\d*)/$3$2$1/;
    Tron::TRACE("fecha: ", $fecha);
    my $v = ($fecha le 20171114);

    # Defino estado esperado como "cualquiera"
    my $xv = "*";
    my $xd = "*";
    my $xb = "*";

    # Extraigo estado esperado del filtro
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
    Tron::TRACE("filtro: ", $xv, $xd, $xb);

    if ($xv != "*" and $xv ne $v) {
        Tron::TRACE("registro rechazado: vencimiento");
        Tron::TRACE();
        return 0;
    }
    if ($xd != "*" and $xd ne $d) {
        Tron::TRACE("registro rechazado: denuncia");
        Tron::TRACE();
        return 0;
    }
    if ($xb != "*" and $xb ne $b) {
        Tron::TRACE("registro rechazado: bloqueo");
        Tron::TRACE();
        return 0;
    }

    Tron::TRACE("registro aceptado");
    Tron::TRACE();
    return 1;
}

# Usa $filtros{"c"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii cuenta =~ /re/
sub filtrarCuentas {
    my @reg = split(/;/, shift @_);
    my $cuenta = @reg[17];

    my %filtros = %{shift @_};

    Tron::TRACE("filtrando por cuenta ", $cuenta);

    if (! exists $filtros{"c"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }

    if ($cuenta =~ /$filtros{"c"}/) {
        Tron::TRACE("registro aceptado");
        Tron::TRACE();
        return 1;
    }

    Tron::TRACE("registro rechazado: ", $cuenta, " no matchea ", $filtros{"c"});
    Tron::TRACE();
    return 0;
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

    Tron::TRACE("filtrando por estado de cuenta ", $estado);

    if (! exists $filtros{"C"}) {
        Tron::TRACE("registro aceptado: no hay filtro");
        Tron::TRACE();
        return 1;
    }

    Tron::TRACE("filtro: ", $filtros{"C"});
    my @f = split(/-/, $filtros{"C"});
    foreach $e (@f) {
        $e = uc($e);
        $estado = uc($estado);
        if ($e eq substr($estado, 0, length($e))) {
            Tron::TRACE("registro aceptado");
            Tron::TRACE();
            return 1;
        }
    }

    Tron::TRACE("registro rechazado");
    Tron::TRACE();
    return 0;
}

1;
