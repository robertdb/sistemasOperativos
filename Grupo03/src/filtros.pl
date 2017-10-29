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
    my $entidad = @reg[21];

    my %filtros = %{shift @_};

    TRACE("filtrando por entidad", $entidad);

    if (! exists $filtros{"e"}) {
        TRACE("registro aceptado: no hay filtro");
        return 1;
    }

    if (!( $filtros{"e"} =~ /^(...)(-(...))?$/ )) {
        TRACE("registro rechazado: filtro mal formado", $filtros{"e"});
        return 0;
    }

    if ($entidad < $1) {
        TRACE("registro rechazado:", $entidad, "<", $1);
        return 0;
    }
    if ($3 =! undef && $3 < $entidad) {
        TRACE("registro rechazado:", $entidad, ">", $3);
        return 0;
    }
    elsif ($3 == undef && $entidad != $1) {
        TRACE("registro rechazado:", $entidad, "!=", $1);
        return 0;
    }

    TRACE("registro aceptado");
    return 1;
}

# Usa $filtros{"f"}, espera uno de los siguientes formatos:
# undef: aceptar
# ddd: aceptar sii fuente es de la forma xxxxxxx_ddd.
sub filtrarFuentes {
    my @reg = split(/;/, shift @_);
    my $fuente = @reg[0];

    my %filtros = %{shift @_};

    TRACE("filtrando por fuente", $fuente);

    if (! exists $filtros{"f"}) {
        TRACE("registro aceptado: no hay filtro");
        return 1;
    }

    $fuente =~ /.*_(\d\d\d).txt/;
    if ($1 == $filtros{"f"}) {
        TRACE("registro aceptado");
        return 1;
    }

    TRACE("registro rechazado:", $fuente, "!=", $1);
    return 0;
}

# Usa $filtros{"d"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii condicion =~ /re/
sub filtrarCondicionesDeDistribucion {
    my @reg = split(/;/, shift @_);
    my $condicion = @reg[6];

    my %filtros = %{shift @_};

    TRACE("filtrando por condicion de distribucion", $condicion);

    if (! exists $filtros{"d"}) { return 1; }
        TRACE("registro aceptado: no hay filtro");


    if ($condicion =~ /$filtros{"d"}/) {
        TRACE("registro aceptado");
        return 1;
    }

    TRACE("registro rechazado:", $condicion, "no matchea", $filtros{"d"});
    return 0;
}

# Usa $filtros{"t"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii tarjeta =~ /re/
sub filtrarTarjetas {
    my @reg = split(/;/, shift @_);
    my $tarjeta = @reg[9];

    my %filtros = %{shift @_};

    TRACE("filtrando por tarjeta", $tarjeta);

    if (! exists $filtros{"t"}) {
        TRACE("registro aceptado: no hay filtro");
        return 1;
    }

    if ($tarjeta =~ /$filtros{"t"}/) {
        TRACE("registro aceptado");
        return 1;
    }

    TRACE("registro rechazado:", $tarjeta, "no matchea", $filtros{"t"});
    return 0;
}

# Usa $filtros{"c"}, espera uno de los siguientes formatos:
# undef: aceptar
# re: aceptar sii cuenta =~ /re/
sub filtrarCuentas {
    my @reg = split(/;/, shift @_);
    my $cuenta = @reg[17];

    my %filtros = %{shift @_};

    TRACE("filtrando por cuenta", $cuenta);

    if (! exists $filtros{"c"}) {
        TRACE("registro aceptado: no hay filtro");
        return 1;
    }

    if ($cuenta =~ /$filtros{"c"}/) {
        TRACE("registro aceptado");
        return 1;
    }

    TRACE("registro rechazado:", $cuenta, "no matchea", $filtros{"c"});
    return 0;
}
