#!/bin/bash
#Script to Analyze MD
#Variables
#Have to be introduced by users before use TOLEDO first time
export SCHRODINGER="/opt/schrodinger/2020-04/"
export SCHRODINGER_PYTHONPATH="" 
S=5 # sampling factor

#Do not change anything below this line

while (( $# ))
 do
    if [[ "$1" == \-[a-z]* ]] || [[ "$1" == \-[A-Z]* ]] || [[ "$1" == \-\-[a-a]* ]] || [[ "$1" == \--[A-Z]* ]];then 
	   case `printf "%s" "$1" | tr '[:lower:]' '[:upper:]'`  in
		-P )  p=$2;;
	 	-L )  L=$2;;
		-T )  T=$2;;
		-F )  F=$2;;
		-G )  G=$2;;
	    esac
	fi
  shift 
done

h=$(hostname)

#Analysis

N=$(($F/$S)) 
echo $N
SMM=$(($F/$T))

eval $(echo "$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/scripts/event_analysis.py analyze DM-Merged-out.cms -p 'protein' -l '( ( res.ptype "UNK" & res.num  "$i") )' -out 'sid$1'")

$SCHRODINGER/run $SCHRODINGER/internal/bin/analyze_simulation.py -s ::$N DM-Merged-out.cms DM-Merged_trj sid$i-out.eaf sid$i-in.eaf 

export QT_QPA_PLATFORM="offscreen"

$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/scripts/event_analysis.py report -pdf DM_$i.pdf -data -plots -data_dir ./dataDM_$i sid$i-out.eaf

singularity exec ../../singularity/TOLEDO.simg python3 ../../Scripts/Graphics.py ./dataDM_$i $time



#PSN Analysis
if [ $L -eq 1 ]
then
for i in $(seq 1 $SMM $F);do
j=$(($i - 1))
echo $j
${SCHRODINGER}/run trj_merge.py DM_Merged-out.cms DM_Merged_trj/ -output-trajectory-format xtc -s $j:$i: -o DM-Merged_split_${i}
mr=("HIE" "HID" "HIP" "HSD" "HSP" "HSE" "CYX" "LYN" "ARN" "ASH" "GLH")
sr=("HIS" "HIS" "HIS" "HIS" "HIS" "HIS" "CYS" "LYS" "ARG" "ASN" "GLU")
for (( j=0; j<${#mr[@]}; j++ )); do
  sed -i "s/${mr[$j]}/${sr[$j]}/g" DM-Merged_split_${i}-out.cms
done
xtc=$(echo DM-Merged_split_"${i%.*}")
echo $xtc
mkdir ${xtc}_psn
mv DM-Merged_split_${i}* ${xtc}_psn
cd ${xtc}_psn
sed "s|TRAJ|${xtc}|" ../../Scripts/ToPDB_P.pml > ToPDB_P_2.pml
sed "s|TOP|${xtc}_PDB|"  ToPDB_P_2.pml >  ToPDB_P_1.pml
singularity exec ../../singularity/TOLEDO.simg  pymol -c ToPDB_P_1.pml
../../Scripts/psntools -calc -pdb ${xtc}_PDB.pdb -wordom ../../Scripts/wordom
../../Scripts/psntools -psg ${xtc}_PDB.psn
cd ..
done
singularity exec ../../singularity/TOLEDO.simg python3 ../../Scripts/PSN.py  DM_Merged_psn.csv
singularity exec ../../singularity/TOLEDO.simg python3 ../../Scripts/PSN_all.py DM_Merged_psn.csv DM_Merged_psn_all.txt
singularity exec ../../singularity/TOLEDO.simg python3 ../../Scripts/PSN_clusters.py DM_Merged_psn.csv DM_Merged_psn_clusters.txt
fi


#MMGBSA Analysis
MMGBSA=$SCHRODINGER/prime_mmgbsa

if [ -f "$MMGBSA" ]
then
   $SCHRODINGER/run thermal_mmgbsa.py DM_Merged-out.cms -step_size $SMM -lig_asl '( ( res.ptype "UNK" & res.num '${L}') )' -j   DM_${L}
    singularity exec ../../singularity/TOLEDO.simg python3 ../../Scripts/MMGBSA.py DM_${L}-prime-out.csv $T MMGBSA_DM_${L}.png
else
   echo "You need a paid version of Maestro"
fi

scancel $SLURM_JOB_ID
