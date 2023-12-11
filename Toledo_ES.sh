#!/bin/bash
#Script to run extension
#Variables
#Have to be introduced by users before use TOLEDO first time
export SCHRODINGER="/opt/schrodinger/2020-04/"
export SCHRODINGER_PYTHONPATH="" 
cluster_perfomace=1 # 1 is for a performance of 24h, 2 for 48h and 0.5 for 12h 


#Do not change anything below this line
while (( $# ))
 do
    if [[ "$1" == \-[a-z]* ]] || [[ "$1" == \-[A-Z]* ]] || [[ "$1" == \-\-[a-a]* ]] || [[ "$1" == \--[A-Z]* ]];then
	   case `printf "%s" "$1" | tr '[:lower:]' '[:upper:]'`  in
		-P )  p=$2;;
	 	-C )  counter=$2;;
		-A )  te=$2;;
		-F )  time=$2;;
		-R )  path=$2;;
		-G )  G=$2;;

	    esac
	fi
  shift 
done

h=$(hostname)
echo "Espacio"
echo "$te"
echo "$time"
echo "Espacio"
#Checks if extension time is equal or greater than final time
if [ "$te" -ge "$time" ];then
	te=$time
fi

#Run MD extension
$SCHRODINGER/run $SCHRODINGER/desmond -JOBNAME DM -HOST $h -restore DM.cpt -in DM-in.cms -cfg mdsim.last_time=$te -WAIT

mv DM_trj/ DM_"$counter"_trj/
mv DM-out.cms DM_"$counter"-out.cms
cp DM.cpt DM_"$counter".cpt


tf=$( cat DM.log | grep Chemical | tail -1 | awk '{ print $3 }' | tr "." "\n" | head -1)
#Checks if extension time is lower than final time
if [ "$tf" -lt "$time" ];then
	#Next MD 
	counter=$(($counter+1))
	speed=$( cat DM.log | grep Chemical | tail -1 | awk '{ print $8 }' | tr "." "\n" | head -1)
	cp DM.log DM_1$counter.log
	increment=$(((($speed*$cluster_perfomace*3000))/4))
	te=$(($tf+$increment))
	echo "$increment">T12.txt
	sbatch $G --mem=20G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=TOLEDO2.out --error=TOLEDO2.err -n 1 ../../Toledo_ES.sh -c $counter -a $te -f $time -d $path -p $p -g $G 
else
  	sbatch $G --mem=20G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=TOLEDO3.out --error=TOLEDO3.err -n 1 ../../Toledo_UN.sh -c $counter -t $time -p $p -g $G


fi

scancel $SLURM_JOB_ID
 


