#!/bin/bash

old_IFS=$IFS
IFS=$'\n'
lines=($($@))
IFS=$old_IFS

len=${#lines[@]}

for (( i=0; i < ${len}; i++ )); do
  set -- ${lines[$i]}
  expr=$1
  shift
  var=$@;
  var=${var%?}
  shift
  case "$expr" in
  PS1)
    PS1=$var;;
  PATH)
    PATH=$var;;
  DYLD_LIBRARY_PATH)
    DYLD_LIBRARY_PATH=$var;;
  LD_LIBRARY_PATH)
    LD_LIBRARY_PATH=$var;;
  C_INCLUDE_PATH)
    C_INCLUDE_PATH=$var;;
  ACLOCAL_PATH)
    ACLOCAL_PATH=$var;;
  PKG_CONFIG_PATH)
    PKG_CONFIG_PATH=$var;
  esac
done
