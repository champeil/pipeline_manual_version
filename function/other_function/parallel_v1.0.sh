#!/bin/bash
# this script is for parallel the sample
# author: laojp
# position: SYSUCC bioinformatics platform
# time: 2023.05.06
# version: 1.0
# usage:
#       (script) &
#       PID=$!
#       PushQue $!
#       while [[ $Nrun -ge $Nproc ]]; do
#               ChkQue
#               sleep 10s
#       done
#       wait_Que
# new: found wait cannot conduct the function likes wait_que, so I write a function 

function PushQue {    # 将PID压入队
        Que="$Que $1"
        Nrun=$(($Nrun+1))
}
function GenQue {     # 更新队列
        OldQue=$Que
        Que=""; Nrun=0
        for PID in $OldQue; do
                if [[ -d /proc/$PID ]]; then
                        PushQue $PID
                fi
        done
        echo -e "\t from ${OldQue} to ${Que} in $(date)" 
}
function ChkQue {     # 检查队列
        OldQue=$Que
        for PID in $OldQue; do
                if [[ ! -d /proc/$PID ]]; then
                        GenQue; break
                fi
        done
}
function wait_Que {
        while [[ -n $Que ]]; do
                sleep 10s
                ChkQue
        done
}
