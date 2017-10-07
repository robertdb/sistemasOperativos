# Este script es una biblioteca. Para invocarla desde use 'source log.sh'

if [ ! -v LOGS ]; then LOGS=log; fi
if [ ! -d $LOGS ]; then mkdir $LOGS; fi

if [ ! -v LOGFILE ]; then LOGFILE=log; fi
if [ -e $LOGS/$LOGFILE ] && [ ! -w $LOGS/$LOGFILE ]; then exit; fi

function log() {
    echo "$@" >>$LOGS/$LOGFILE
}
