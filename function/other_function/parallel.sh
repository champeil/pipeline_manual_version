#second example: control the parallel samples number once
#then add new process automatically when one or more process in the array is ended
function PushQue {    # 将PID压入队列
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
                if [[ ! -d /proc/$PID ]] ; then
                        GenQue; break
                fi
        done
}
