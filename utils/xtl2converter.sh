#!/bin/bash
inp_xtl=$1
fmt=$2
if [[ $1 == "" ]]; then
  echo "usage: $0 inp_xtl [open-babel-fmt]"
  exit 1
fi
if [[ $2 == "" ]]; then
  fmt="aims"
fi


tmp=${inp_xtl%.xtl}.aims
output=${inp_xtl%.xtl}.$fmt

grep -A1 CELL $inp_xtl | tail -n 1 > tmp_cell_abc_angles

sed -n '/ATOMS/,/EOF/p' $inp_xtl | grep -v -e ATOMS -e NAME -e EOF \
  | awk '{print $1}' > tmp_atoms_spe

sed -n '/ATOMS/,/EOF/p' $inp_xtl | grep -v -e ATOMS -e NAME -e EOF \
  | awk '{$1=""}{print $0}' > tmp_atoms_frc

cat > tmp_conv.m << EOF
load tmp_cell_abc_angles
a = tmp_cell_abc_angles(1);
b = tmp_cell_abc_angles(2);
c = tmp_cell_abc_angles(3);
alpha = tmp_cell_abc_angles(4)/180*pi;
beta = tmp_cell_abc_angles(5)/180*pi;
gamma = tmp_cell_abc_angles(6)/180*pi;
lattice = [a,            0,            0; 
           b*cos(gamma), b*sin(gamma), 0;
           c*cos(beta),  c*(cos(alpha)-cos(beta)*cos(gamma))/sin(gamma), c*sqrt( 1 + 2*cos(alpha)*cos(beta)*cos(gamma) - cos(alpha)^2-cos(beta)^2-cos(gamma)^2 )/sin(gamma)];
h = lattice';
save -ascii 'tmp_latt' lattice
load tmp_atoms_frc
s = tmp_atoms_frc;
r = (h*s')';
save -ascii 'tmp_r' r
EOF
octave tmp_conv.m

awk '{print "lattice_vector", $0}' tmp_latt > $tmp
paste ./tmp_r ./tmp_atoms_spe | awk '{print "atom", $0}' >> $tmp

if [[ $fmt != "fhiaims" && $fmt != "aims" ]]; then
  obabel -ab -ifhiaims $tmp -o$fmt -O $output > /dev/null # "b" option from -a is to Disable bonding entirely (important for speed)
  rm -f $tmp
  echo "generated $output"
else
  echo "generated $tmp"
fi

rm -f tmp_cell_abc_angles tmp_atoms_spe tmp_atoms_frc tmp_conv.m tmp_latt tmp_r
