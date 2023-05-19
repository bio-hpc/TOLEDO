#!/bin/bash
#Firs script with a short (1ns) MD
#Variables
#Have to be introduced by users before use TOLEDO first time
export SCHRODINGER="/home/miguel/opt/schrodinger/2020-04/"
export SCHRODINGER_PYTHONPATH="" 
cluster_perfomace=1 # 1 is for a performance of 24h, 2 for 48h and 0.5 for 12h 

#Do not change anything below this line
while (( $# )) 
 do
    if [[ "$1" == \-[a-z]* ]] || [[ "$1" == \-[A-Z]* ]] || [[ "$1" == \-\-[a-a]* ]] || [[ "$1" == \--[A-Z]* ]];then 
	   case `printf "%s" "$1" | tr '[:lower:]' '[:upper:]'`  in
	   	-T )  t=$2;;			#time in ps (Mandatory)
		-P )  p=$2;;                    #partition (Mandatory)
		-D )  d=$2;;                    #path (Mandatory) 
		-X ) prot=$2;; 			#protein file name (Optional)
		-Y ) lig=$2;;			#ligand file name (Optional)
		-W ) MDM=$2;;				
		-E ) MDC=$2;;
		-R ) WBM=$2;;
		-G ) G=$2;;
		-M ) m=$2;;
		-C ) c=$2;;
	    esac
	fi
  shift 
done

h=$(hostname)


if [[ $m != "y" ]];then 
#Build complexes

ext="${prot##*.}"
prot="$(basename "$prot" | sed 's/\(.*\)\..*/\1/')"

if [[ $ext == "mol2" ]] 
then
echo "mol2 file"
$SCHRODINGER/utilities/mol2convert  -all -imol2 "$prot".mol2 -omae "$d/protein.mae"
cp "$prot".mol2 "$d/protein.mol2"
elif [[ $ext == "mae" ]]
then
echo "mae file"
$SCHRODINGER/utilities/mol2convert  -all -imae "$prot".mae -omol2 "$d/protein.mol2"
cp "$prot".mae "$d/protein.mae"
else 
echo "Error: Incorrect extension file"
fi

ext="${lig##*.}"
lig="$(basename "$lig" | sed 's/\(.*\)\..*/\1/')"
echo $lig
if [[ $ext == "mol2" ]] 
then
echo "mol2 file"
$SCHRODINGER/utilities/mol2convert  -all -imol2 "$lig".mol2 -omae "$d/ligand.mae"
cp "$lig".mol2 "$d/ligand.mol2"
elif [[ $ext == "mae" ]]
then
echo "mae file"
$SCHRODINGER/utilities/mol2convert  -all -imae "$lig".mae -omol2 "$d/ligand.mol2"
cp "$lig".mae "$d/ligand.mae"
else 
echo "Error: Incorrect extension file"
fi
cat "$d/protein.mae" "$d/ligand.mae" > "$d/complex.mae" 

#Build of water box (WB)
charge=$( python ../Scripts/CheckCharges.py "$d/protein.mol2" "$d/ligand.mol2")

cd "$d/"
if [[ ! -z $WBM ]] #Check WB parameters
then
cp $WBM desmond_setup_test_toledo.msj
elif [[ $charge == "Negative" ]]
then
cp ../../WB/WB_Negative.msj desmond_setup_test_toledo.msj
else
cp ../../WB/WB_Positive.msj desmond_setup_test_toledo.msj
fi

$SCHRODINGER/utilities/multisim -JOBNAME desmond_setup_test_toledo -m desmond_setup_test_toledo.msj complex.mae -o complex_WB-out.cms -HOST $h 
sleep 360

fi

counter=1 #counter to obtain final MD 

tiempo=$t #Ending time of MD


if [[ ! -z $MDM ]] && [[ ! -z $MDC ]]  #Check MD parameters
then
cp $MDM ./MD.msj
cp $MDC ./MD.cfg
else
cp ../../MD/MD.msj ./MD.msj
cp ../../MD/MD.cfg ./MD.cfg
fi


if [[ $m == "Y" ]];then
cd "$d/"
cp $c $d/complex_WB-out.cms
fi
 
$SCHRODINGER/utilities/multisim -JOBNAME DM  -HOST $h -maxjob 1 -cpu 24 -m MD.msj -c MD.cfg -description "Molecular Dynamics" complex_WB-out.cms -mode umbrella -o complex_MD-out.cms -set stage[1].set_family.md.jlaunch_opt=[\"-gpu\"] -WAIT > Dinamica.txt 2> Dinamica.err 

mv DM_trj/ DM_"$counter"_trj/
mv DM-out.cms DM_"$counter"-out.cms
cp DM.cpt DM_"$counter".cpt

counter=$(($counter+1))
tf=$( cat DM.log | tail -10 | head -1 | awk '{ print $3 }' | tr "." "\n" | head -1)
echo $tf
speed=$( cat DM.log | tail -10 | head -1 | awk '{ print $8 }' | tr "." "\n" | head -1)
increment=$(((($speed*3))/4)) $(($speed*$cluster_perfomace))
te=$(($tf+$increment)) #Extension time of the next MD

sbatch $G --gres=gpu:1 --mem=20G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=TOLEDO1.out --error=TOLEDO1.err -n 1 ../../Toledo_ES.sh -c $counter -a $te -f $tiempo -r $d -p $p -g $G 

scancel $SLURM_JOB_ID
