validar();
# c,t,d,e,f
# e puede venir con rango
sub validar {
    print "Ingrese el filtro, manera c20,e20-323,f20,t2020\n";
    print "O ingrese * para TODOS \n";
    $filtro = <STDIN>;
    chomp($filtro);

    TRACE("Filtro es", $filtro);
    if ($filtro eq "0") { return $filtro; }
    if ($filtro eq "*") { return $filtro; }

    $incorrecto = 1;
    while ( $incorrecto == 1 ) {
        TRACE("entrando al loop");

        @array=split(',',$filtro);
        $hayIncorrecto = 0;
        foreach $cosa (@array) {
            TRACE("foreach:", $cosa);
            if ( $cosa =~ /^[c,t,d,e,f].*/) {
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
