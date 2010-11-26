#!/bin/sh

for filename in *.csv
do
  echo Procurando linhas duplicadas em: $filename
  sort $filename | uniq -d
done;

