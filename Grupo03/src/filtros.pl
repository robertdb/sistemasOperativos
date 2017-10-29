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
    while ( ($temp = chop($filtro)) == "" ) {
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
