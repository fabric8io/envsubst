#!/bin/bash

FILENAME=$1

if [ ! $FILENAME ]
then
  echo 'No filename argument provided'
  exit -1
fi
echo "Processing $FILENAME ..."

envsubst < $FILENAME > $FILENAME-bak
mv $FILENAME-bak /processed/$FILENAME
