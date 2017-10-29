validar("c,e,f,d,g");
# c,t,d,e,f 
# e puede venir con rango 
sub validar{
 my ($filtro) = @_;
 $incorrecto = 1;
# Para salir del while debe ser 0
 while ( $incorrecto == 1 ){
  print "$filtro \n";
   if ($filtro eq "*") {
       print "paso, es *\n";
       $incorrecto = 0;
   } 
   else{
       @array=split(',',$filtro);
       $hayIncorrecto = 0;
       foreach $cosa (@array){
        if ( $cosa =~ /^[c,t,d,e,f].*/) {
          
        } else {
          $hayIncorrecto = 1;
 	  last;
        }
       } # fin Foreach
# Cuando termina el ciclo, si hay uno malo ---> hayIncorrecto = 1 
          
       if ($hayIncorrecto eq 1) {
          print "Error: modo de filtro invalido, reingrese\n";
          $filtro = <STDIN>;
          chomp($filtro);
        } else {
        $incorrecto = 0;
        }

     }  # Fin else
   } #Fin While
  return $filtro;
} #Fin funcion
