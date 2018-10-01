#! /bin/bash

# echo "#########    HEALTH CHECK REPORT    #########"
echo "=============================================="
echo "            SYSTEM INFORMATION                "
echo "=============================================="
hostnamectl | grep -iv 'icon name' | grep -iv 'chassis' | grep -iv 'machine id'| grep -iv 'boot id'

echo "=============================================="
echo "             CPU INFORMATION                   "
echo "=============================================="
    
if [ -e /usr/bin/mpstat ]; then
    cores=$(lscpu | grep -i '^cpu(s):' | awk '{print $2}')
    for (( each_core=0; each_core < $cores; each_core++ ))
        do
            echo "CPU $each_core: " `mpstat -P ALL | tail -n +5 | awk '$3 == '$each_core' {printf .2f, 100-$13}'`"%"
	done
else
   echo "### UNABLE TO RETRIEVE CPU CORE LEVEL INFORMATON ###"
fi

echo "#####################"
echo "# LOAD AVG: " `cat /proc/loadavg | awk '{print $1}'` "  #"
echo "#####################"
echo "If LOAD AVG <" ` echo "scale=2; $cores/scale" | bc -l` " ===>> HEALTH STATUS : 'NORMAL'"
echo "If LOAD AVG >" ` echo "scale=2; $cores/scale" | bc -l` " ===>> HEALTH STATUS : 'CRITICAL'"
echo "If LOAD AVG >= $cores    ===>> HEALTH STATUS : 'UNHEALTHY'"

echo -e "\n"
echo "**********************************************"
echo "   Top 10 Processes consuming more CPU        "
echo "**********************************************"
ps -eo pid,ruser,pcpu,pmem,comm --sort=-pcpu | head -n 11
echo -e "\n"
echo "=============================================="
echo "            MEMORY INFORMATON                   "
echo "=============================================="
free -h | grep -i mem | awk '{print "Total MEMORY :: " $2 "\t MEMORY IN USE :: " $3"\tFREE ::"$4}'
echo "     "
free -h | grep -i swap | awk '{print "Total SWAP   :: " $2 "\t SWAP IN USE   :: " $3"\tFREE ::"$4}'
echo -e "\n"
echo "**********************************************"
echo "   Top 10  Processes consuming more Memory    "
echo "**********************************************"
ps -eo pid,ruser,pcpu,pmem,comm --sort=-pmem | head -n 11 

echo "=============================================="
echo "              DISK UTILIZATION                "
echo "=============================================="

echo "Total DISK SPACE :: " `df -h --output=size --total | awk 'END {print $1}'`

df -Th | awk '{print $3,"\t",$4,"\t",$5,"\t",$7}'
echo -e "\n"
echo "*******************************************"
echo "If DiskUsage  <  80  'NORMAL'"
echo "If DiskUsage  >= 80 OR < 90  'CAUTION'"
echo "If DiskUsage  >= 90  'CRITICAL'"
echo "*******************************************"
n_filesystems=$(df -Th | tail -n +2 | wc -l)
for((i=1;i<=n_filesystems;i++))
do
    utilization_perc=$(df -Th | tail -n +2 | awk 'NR=='$i' {print $6}' | cut -d'%' -f1)
    fs_name=$(df -Th | tail -n +2 | awk 'NR=='$i' {print $7}')
    if [ $utilization_perc -lt 80 ]; then
        echo -e "NORMAL   \t ==>> \t $fs_name"
    elif [ $utilization_perc -ge 80 -o $utilization_perc -lt 90 ]; then
        echo -e "CAUTION  \t ==>> \t $fs_name"     
    else
        echo -e "CRITICAL \t ==>> \t $7"     
    fi
done
print("validatig")
