#!/bin/bash
#Script to Analyze MD
#Variables
#Have to be introduced by users before use TOLEDO first time
export SCHRODINGER="/home/miguel/opt/schrodinger/2020-04/"
export SCHRODINGER_PYTHONPATH="" 

#Do not change anything below this line

while (( $# ))
 do
    if [[ "$1" == \-[a-z]* ]] || [[ "$1" == \-[A-Z]* ]] || [[ "$1" == \-\-[a-a]* ]] || [[ "$1" == \--[A-Z]* ]];then 
	   case `printf "%s" "$1" | tr '[:lower:]' '[:upper:]'`  in
		-P )  p=$2;;
	 	-L )  i=$2;;
		-T )  time=$2;;
		-F )  N=$2;;
		-G )  G=$2;;
	    esac
	fi
  shift 
done

h=$(hostname)

#Analysis


eval $(echo "$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/scripts/event_analysis.py analyze DM-Merged-out.cms -p 'protein' -l '( ( res.ptype "UNK" & res.num  "$i") )' -out 'sid$1'")

$SCHRODINGER/run $SCHRODINGER/internal/bin/analyze_simulation.py -s ::$N DM-Merged-out.cms DM-Merged_trj sid$i-out.eaf sid$i-in.eaf 

export QT_QPA_PLATFORM="offscreen"

$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/scripts/event_analysis.py report -pdf DM_$i.pdf -data -plots -data_dir ./dataDM_$i sid$i-out.eaf

python3 ../../Scripts/Graphics.py ./dataDM_$i $time

scancel $SLURM_JOB_ID
