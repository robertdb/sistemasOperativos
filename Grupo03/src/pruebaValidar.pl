validar();
# c,t,d,e,f 
# e puede venir con rango 
sub validar{

# my ($filtro) = @_;
  print "Ingrese el filtro, manera c20,e20-323,f20,t2020\n"; 
  print "O ingrese * para TODOS \n";
  $filtro = <STDIN>;
  chomp($filtro);  
  

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
