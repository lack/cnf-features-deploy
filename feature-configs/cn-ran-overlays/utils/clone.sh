#!/bin/sh
#
# Clone one example to another

if [[ -z $1 || -z $2 || -z $3 ]]; then
  echo "Usage:"
  echo "./clone.sh <path> <from> <to>"
  echo "<path> - path to the <from> or the <to>,\
  for example '../'"
  echo "<from> - the name of the source forder,\
  for example 'du-ldc'"
  echo "<to> - the name of the destination forder,\
  for example du-ldc-2"
  echo 'For example: "./clone.sh ../ du-ldc du-ldc-2"'
  exit 1
fi

# Network resource can't contain dashes
# We replace them by underscores
NR_FROM=$(echo $2 | sed -e 's/-/_/')
NR_TO=$(echo $3 | sed -e 's/-/_/')

cp -rf $1/$2 $1/$3

find $1/$3 -type f -exec sed -i -e "'s/'$2'/'$3'/g'" {} +
find $1/$3 -type f -exec sed -i -e "'s/'$NR_FROM'/'$NR_TO'/g'" {} +
find $1/$3 -name '*'$2'*' -exec rename '*'$2'*' '*'$3'*' {} +
