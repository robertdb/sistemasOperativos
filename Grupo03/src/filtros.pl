# Todas las subrutinas reciben
#   $registro (string) valor del registro como se encuentra en el archivo
#   \%filtros (hash) conjunto de filtros en los que buscar
#
# Todas las funciones evaluan a verdadero si y solo si el registro
# cumple con el filtro y debe ser aceptado.

# Usa $filtros{"e"}
sub filtrarEntidades {
    my @reg = split(/;/, shift @_);
    my $entidad = @reg[21];

    my %filtros = %{shift @_};

    if (! exists $filtros{"e"}) { return 1; }

    if (!( $filtros{"e"} =~ /^(...)(-(...))?$/ )) { return 0; }

    if ($entidad < $1) { return 0; }
    if ($3 =! undef && $3 < $entidad) { return 0; }
    elsif ($3 == undef && $entidad != $1) { return 0; }

    return 1;
}

# Usa $filtros{"f"}
sub filtrarFuentes {
    my @reg = split(/;/, shift @_);
    my $fuente = @reg[0];

    my %filtros = %{shift @_};

    if (! exists $filtros{"f"}) { return 1; }

    $fuente =~ /.*_(\d\d\d).txt/;
    if ($1 == $filtros{"f"}) { return 1; }

    return 0;
}

# Usa $filtros{"d"}
sub filtrarCondicionesDeDistribucion {
}

# Usa $filtros{"t"}
sub filtrarTarjetas {
}

# Usa $filtros{"c"}
sub filtrarCuentas {
}
