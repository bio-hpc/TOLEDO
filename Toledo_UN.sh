#!/bin/bash
#Script to Merged MD
#Variables
#Have to be introduced by users before use TOLEDO first time
export SCHRODINGER="/opt/schrodinger/2020-04/"
export SCHRODINGER_PYTHONPATH="" 

#Do not change anything below this line
while (( $# )) 
 do
    if [[ "$1" == \-[a-z]* ]] || [[ "$1" == \-[A-Z]* ]] || [[ "$1" == \-\-[a-a]* ]] || [[ "$1" == \--[A-Z]* ]];then #
	   case `printf "%s" "$1" | tr '[:lower:]' '[:upper:]'`  in
		-P )  p=$2;; # partition
	 	-C )  counter=$2;; # counter of the parts
		-T )  time=$2;; #time in ps
		-G )  G=$2;; 
	    esac
	fi
  shift 
done


h=$(hostname)

$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/common/split_structure.py complex.mae -many_files Part.mol2 ;  $SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/common/split_structure.py Part_chain_.mol2 -many_files -m ligand Lig.mol2 > NLigands.txt;cat NLigands.txt | tail -2 | head -1 | awk '{ print $5 }' >  T1.txt


NL=$( cat T1.txt | tr -d "\n")
echo $NL

traj=$( echo "")
for i in $(seq 1 1 $counter)
do
traj=$( echo "$traj DM_"$i"_trj")
done 

$SCHRODINGER/run trj_merge.py DM_"$counter"-out.cms $traj -o DM-Merged > Frames.txt
FRAMES=$( cat Frames.txt | tail -1 | awk '{ print $5 }' | tr "." "\n" | head -1)

#Script to do a sampling of X frames to optimize the time of analysis(the number 5 can be changed)
echo $FRAMES

if [[ "$NL" -ge "2" ]];then
for i in $(seq 1 1 $NL)
do
sbatch $G --mem=20G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=TOLEDO.out --output=TOLEDO.err -n 1 ../../Toledo_AN_M.sh -l $i -f $FRAMES -t $time -r $ruta -p $p -g $G
done
else 
sbatch $G --mem=20G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=TOLEDO.out --output=TOLEDO.err -n 1 ../../Toledo_AN_1.sh -f $FRAMES -t $time -r $ruta -p $p -g $G
fi

