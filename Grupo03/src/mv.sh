# Mover archivos manejando colisiones de nombres
#
# Uso: _mv directorio archivo...
#
# Si el nombre de un archivo a mover coincide con el de uno ya existente
# en el directorio de destino, el programa mueve el archivo a
# directorio/dup y le agrega un prefijo de dos digitos de forma tal que
# el nombre no colisione con ninguno de los archivos existentes en dup.
# El archivo que originalmente existia en directorio no se ve aceptado.
function _mv() {
    local dir=${1:?_mv llamado sin argumentos}; shift
    if ! [ -d $dir ]; then
        echo "argumento 1 $1 de _mv no era un directorio" >&2
    fi

    for file in $@; do
        # Que pasa si $dir termina en / ?
        local bn=$(basename $file)
        local dest="$dir/$bn"
        if [ -f $dest ]; then
            mkdir --parents $dir/dup
            local dup=$(ls $dir/dup | grep "^[0-9][0-9]$bn" | tail --lines=1)
            local n=${dup::2}
            n=$(printf %02d $(($n + 1)))
            dest="$dir/dup/$n$bn"
        fi
        mv $file $dest
    done
}
