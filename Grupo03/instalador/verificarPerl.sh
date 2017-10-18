#Verifico si esta instalado el perl
VALOR=$(command -v perl)
#Si esta instalado en VALOR se obtiene la ruta donde esta instalado
if [ ! -z "$VALOR" -a "$VALOR" != " " ]; then
	mensaje "Perl esta instalado"
#Saco la version del perl
	Version=$(perl -v | grep 'This is perl' | sed "s/This is perl \([0-9]\),.*/\1/")
#Verifico que la version sea 5 o mas
	if (($Version >= 5)); then
		mensaje "Version de Perl: $Version"
	fi
else 
#Si el perl no esta instalado avisa y sale de la ejecucion
	mensaje "Perl no esta instalado"
	exit 1
fi
