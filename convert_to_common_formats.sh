#!/bin/bash
ROOT_d=$PWD
conv_f=$ROOT_d/utils/xtl2converter.sh
XTL_d=$ROOT_d/a-SiNx-xtl/
#for fmt in pdb cif aims
for fmt in aims
do
  WRK_d=$ROOT_d/a-SiNx-$fmt
  rm -rf $WRK_d
  cp -r $XTL_d $WRK_d
  cd $WRK_d
  for c in `ls *.xtl`
  do
    $conv_f $c $fmt
  done
  rm -f *.xtl
  cd $ROOT_d
done
