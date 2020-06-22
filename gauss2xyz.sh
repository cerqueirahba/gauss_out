#!/bin/bash
#
### Script to get XYZ from Gaussian output
#

# Gaussian output file:
GAUSS_OUT=$1
BASE_NAME=`echo $GAUSS_OUT | cut -d "." -f 1`

# Number of normal modes:
NATOMS=42

# XYZ geomtry from gaussian output:
GEOM="$BASE_NAME.xyz"
CUT_TOP=`grep -n "Number     Number       Type             X           Y           Z" $GAUSS_OUT | tail -1 | cut -d ":" -f 1`
CUT_BOTTOM=`grep -n "Rotational constants (GHZ):" $GAUSS_OUT | tail -2 | head -1 | cut -d ":" -f -1`
F_LINE=$((CUT_TOP+2))
L_LINE=$((CUT_BOTTOM-2))
sed -n "$F_LINE,$L_LINE p" $GAUSS_OUT >> geom-cut.TMP
awk '{print $2 " " $4 " " $5 " " $6}' geom-cut.TMP >> geom.TMP

# Replacing atomic numbers for atomic symbols:
awk '{print $1}' geom.TMP               > ATOMS.TMP
awk '{print $2 " " $3 " " $4}' geom.TMP > COORD.TMP

# Atoms:
sed -i "s/3/Li/" ATOMS.TMP  # Hidrogênio
sed -i "s/9/F/" ATOMS.TMP  # Carbono

paste ATOMS.TMP COORD.TMP > XYZ.TMP

echo "$NATOMS"     >> $GEOM
echo "$BASE_NAME"  >> $GEOM
cat XYZ.TMP        >> $GEOM

# Removing tmp files:
#rm *.TMP

echo "XYZ file:"
echo "$GEOM"

