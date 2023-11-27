#!/bin/bash

source $(dirname "$0")/../../.test/test.sh

BINARY=start
OUTPUT=/tmp/output.txt
TIMEOUT=30
SKIPPED=0


init_feedback "Esercizio load balancing"

compile_and_run $BINARY $OUTPUT $TIMEOUT


perl -n -e 'BEGIN { %pid=(); $cur_server=0; $sent=0; $received=0; }  if(/Client\s(\d+):\sinvio\smessaggio\snumero\s(\d+)/) { $pid{$1}++; $sent++; }  if(/Balancer:\sricezione\smessaggio\sdal\sprocesso\s(\d+),\sinvio\sal\sserver\s(\d)/) { if(! exists $pid{$1}) { exit(1); } if($2!=$cur_server+1) { exit(1); } $cur_server=($cur_server+1)%3; } if(/Server\s\d+:\sricezione\smessaggio\snumero\s\d+\sdal\sprocesso\s(\d+)/) { if(! exists $pid{$1}) { exit(1); } $received++; } END { if($sent!=$received) { exit(1); } }' $OUTPUT

if [ $? -ne 0 ]
then
    failure "L'esecuzione non invia correttamente i messaggi"
fi


static_analysis


success


