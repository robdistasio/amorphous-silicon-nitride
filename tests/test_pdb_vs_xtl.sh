#!/bin/bash
for i in `seq 100`
do
  awk '/CRYST1/{{a=$2}{b=$3}{c=$4}}/HETATM/{print $6/a,$7/b,$8/c}' ../a-SiNx-pdb/3.01-${i}.pdb > s_pdb.dat
  sed -n '/NAME   X  Y  Z/,/EOF/p' ../a-SiNx-xtl/3.01-${i}.xtl | grep -v -e NAME -e EOF | awk '{$1=""}{print $0}' > s_xtl.dat
  paste s_pdb.dat s_xtl.dat | awk '{ds1=$1-$4}{ds2=$2-$5}{ds3=$3-$6}{ds+=ds1*ds1+ds2*ds2+ds3*ds3}END{print "conf'$i': RMSD", sqrt(ds/NR)}'
  rm -f s_pdb.dat s_xtl.dat
done
