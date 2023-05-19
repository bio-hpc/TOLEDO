#!/bin/bash
counterd=1
while (( $# )) 
 do
    if [[ "$1" == \-[a-z]* ]] || [[ "$1" == \-[A-Z]* ]] || [[ "$1" == \-\-[a-a]* ]] || [[ "$1" == \--[A-Z]* ]];then 
	   case `printf "%s" "$1" | tr '[:lower:]' '[:upper:]'`  in
	   	-T )  t=$2;;			#time in ps (Mandatory)
		-F )  f=$2;;			#file  with protein and ligand / complex (Mandatory) and (optional) with msj file of WB and msj and cfg files of MD
		-P )  p=$2;;                    #partition (Mandatory)
		-D )  d=$2;;                    #path (Mandatory)
		-G ) G=$2;;                     # GPU parameters (Optional)
		-M ) m=$2;;			# Membrane: Y/N (Optional, default parameter is N)
	    esac
	fi
  shift 
done
mkdir $d
if [[ $m == "Y" ]] || [[ $m == "y" ]];then # Check of membrane
	m="y"
elif [[ -z $m ]] || [[ $m == "N" ]] || [[ $m == "n" ]];then
	m="n"
else
	echo "Incorrect value to parameter m, please choice between Y/y or N/n"
fi



if [[ $m == "n" ]];then
	echo "without membrane";
	while IFS= read -r line;do
		cd $d;mkdir $counterd; cd ../
		protein=$(echo $line | cut -f1 -d " ")
		ligand=$(echo $line | cut -f2 -d " ")
		#Check of optional parameter 1 
		optional1=$(echo $line | cut -f3 -d " ")
		optional1T=$(echo $optional1 | cut -f1 -d "=")
		if [[ $optional1T == "--WBM" ]]  &&  [[ ! -z $optional1 ]];then
			WBM=$(echo $optional1 | cut -f2 -d "=" )
		elif [[ $optional1T == "--MDM" ]]  &&  [[ ! -z $optional1 ]];then
			MDM=$(echo $optional1 | cut -f2 -d "=" )
		elif [[ $optional1T == "--MDC" ]]  &&  [[ ! -z $optional1 ]];then
			MDC=$(echo $optional1 | cut -f2 -d "=" )
		elif [[ ! -z $optional1 ]];then 
			ERROR=$(echo "Error in the configuration. Check all the parameters")
		fi


		#Check of optional parameter 2
		optional2=$(echo $line | cut -f4 -d " ")
		optional2T=$(echo $optional2 | cut -f1 -d "=")
		if [[ $optional2T == "--WBM" ]] &&  [[ ! -z $optional2 ]];then
			WBM=$(echo $optional2 | cut -f2 -d "=" )
		elif [[ $optional2T == "--MDM" ]]  &&  [[ ! -z $optional2 ]];then
			MDM=$(echo $optional2 | cut -f2 -d "=" )
		elif [[ $optional2T == "--MDC" ]]  &&  [[ ! -z $optional2 ]];then
			MDC=$(echo $optional2 | cut -f2 -d "=" )
		elif [[ ! -z $optional2 ]];then 
			ERROR=$(echo "Error in the configuration. Check all the parameters")
		fi

		#Check of optional parameter  3
		optional3=$(echo $line | cut -f5 -d " ")
		optional3T=$(echo $optional3 | cut -f1 -d "=")
		if [[ $optional3T == "--WBM" ]]  &&  [[ ! -z $optional3 ]];then
			WBM=$(echo $optional3 | cut -f2 -d "=" )
		elif [[ $optional3T == "--MDM" ]]  &&  [[ ! -z $optional3 ]];then
			MDM=$(echo $optional3 | cut -f2 -d "=" )
		elif [[ $optional3T == "--MDC" ]]  &&  [[ ! -z $optional3 ]];then
			MDC=$(echo $optional3 | cut -f2 -d "=" )
		elif [[ ! -z $optional3 ]];then 
			ERROR=$(echo "Error in the configuration. Check all the parameters")
		fi

		#Check of optional parameter  4
		optional4=$(echo $line | cut -f6 -d " ")
		if [[ ! -z $optional4 ]];then 
			ERROR=$(echo "Error in the configuration. Excess of parameters")
		fi


		#Launcher of TOLEDO:
		if [[ -z $WBM ]] && [[ -z $MDM ]] && [[ -z $MDC ]] && [[ -z $ERROR ]];then # Script without special configuration
			sbatch $G --gres=gpu:1 --mem=20G  --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p "$p" --output=$d/$counterd/TOLEDO.out --error=$d/$counterd/TOLEDO.err -n 1 ./Toledo_Main.sh -X "$protein" -Y "$ligand" -t $t -p $p -d $d/$counterd -G "$G"
		elif [[ -z $MDM ]] && [[ -z $MDC ]] && [[ ! -z $WBM ]] && [[ -z $ERROR ]];then #Script with special water box (WB)
			sbatch $G --gres=gpu:1 --mem=20G  --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=$d/TOLEDO.out --error=$d/TOLEDO.err -n 1 ./Toledo_Main.sh -Y $protein -X $ligand -t $t -p $p -d $d -WBM $WBM -G $G
		elif [[ -z $WBM ]]  && [[ ! -z $MDM ]] && [[ ! -z $MDC ]] && [[ -z $ERROR ]];then  #Script with special MD parameters 
			sbatch $G --gres=gpu:1 --mem=20G  --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=$d/TOLEDO.out --error=$d/TOLEDO.err -n 1 ./Toledo_Main.sh -X $protein -Y $ligand -t $t -p $p -d $d -MDC $MDC -MDM $MDM -G -$G
		elif [[ ! -z $WBM ]]  && [[ ! -z $MDM ]] && [[ ! -z $MDC ]] && [[ -z $ERROR ]];then #Script with special WB and MD parameters
			sbatch --gres=gpu:1 --mem=20G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=$d/TOLEDO.out --error=$d/TOLEDO.err -n 1 ./Toledo_Main.sh -X $protein -Y $ligand -t $t -p $p -d $d -WBM $WBM -MDC $MDC -MDM $MDM -G -$G
		else #Lack or excess of files
			echo "Error in the parameters configuration. Lack/Excess or parameters" 
		fi
		MDC=""
		MDM=""
		WBM=""
		ERROR=""
		counterd=$(($counterd+1))

	done < $f
else
	while IFS= read -r line;do
	cd $d;mkdir $counterd; cd ../
	  complex=$(echo $line | cut -f1 -d " ") 
	  #Check of optional parameter  1
	  optional1=$(echo $line | cut -f2 -d " ")
	  optional1T=$(echo $optional1 | cut -f1 -d "=")
	  if [[ $optional1T == "--MDM" ]]  &&  [[ ! -z $optional1 ]];then
		  MDM=$(echo $optional1 | cut -f2 -d "=" )
	  elif [[ $optional1T == "--MDC" ]]  &&  [[ ! -z $optional1 ]];then
		  MDC=$(echo $optional1 | cut -f2 -d "=" )
	  elif [[ ! -z $optional1 ]];then 
		  ERROR=$(echo "Error in the configuration")
	  fi
	  
	  # Script without special configuration
	  if [[ $complex == $optional1 ]];then
          sbatch --gres=gpu:1 --mem=4G --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=$d/$counterd/TOLEDO.out --error=$d/$counterd/TOLEDO.err -n 1 ./Toledo_Main.sh -c $complex -t $t -p $p -m y -d $d/$counterd -G $G
          echo "Membrana"
	  else 
	  #Check of optional parameter  2
	  optional2=$(echo $line | cut -f3 -d " ")
	  optional2T=$(echo $optional2 | cut -f1 -d "=")
	  if [[ $optional2T == "--MDM" ]]  &&  [[ ! -z $optional2 ]];then
	  	MDM=$(echo $optional2 | cut -f2 -d "=" )
	  elif [[ $optional2T == "--MDC" ]]  &&  [[ ! -z $optional2 ]];then
	  	MDC=$(echo $optional2 | cut -f2 -d "=" )
	  elif [[ ! -z $optional2 ]];then
	  	ERROR=$(echo "Error in the configuration. Check all the parameters")
	  fi	  

	  #Check of optional parameter  3
	  optional4=$(echo $line | cut -f4 -d " ")
	  if [[ ! -z $optional4 ]];then 
		  ERROR=$(echo "Error in the configuration.Excess of parameters")
	  fi
      if [[ ! -z $MDM ]] && [[ ! -z $MDC ]] && [[ -z $ERROR ]];then #Script with special MD parameters
		  sbatch $G --gres=gpu:1 --mem=20G  --time=24:00:00 --cpus-per-task=8 -J TOLEDO -p $p --output=$d/TOLEDO.out --output=$d/TOLEDO.err -n 1 ./Toledo_Main.sh -c $complex -t $t -p $p -d $d -MDC $MDC -MDM $MDM -G -$G -m "y"
	  else #Lack or excess of files
		  echo "Error in the parameters configuration. Check all the parameters"
	  fi
	  fi
	  MDC=""
	  MDM=""
	  ERROR=""
	  counterd=$(($counterd+1));echo $counterd

done < $f
fi
