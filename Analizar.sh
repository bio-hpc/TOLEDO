export SCHRODINGER=/home/miguel/desmond_free/2020_4/
export SCHRODINGER_PYTHONPATH=" "
h=$(hostname)

$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/scripts/event_analysis.py analyze $1 -p 'chain .A' -l 'auto' -out 'sid' 

$SCHRODINGER/run $SCHRODINGER/internal/bin/analyze_simulation.py $1 $2 sid-out.eaf sid-in.eaf 

export QT_QPA_PLATFORM="offscreen"
$SCHRODINGER/run $SCHRODINGER/mmshare-v*/python/scripts/event_analysis.py report -pdf DataDM.pdf -data -plots -data_dir ./DataDM sid-out.eaf
