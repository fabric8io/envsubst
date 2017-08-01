#!/bin/bash

PROCESSED=false

for i do
  echo "Processing $i ..."

  envsubst < /workdir/$i > /processed/$i
  PROCESSED=true
done

ls /processed/

if [ ! $PROCESSED = true ]
then
  echo 'No files processed'
  exit -1
fi