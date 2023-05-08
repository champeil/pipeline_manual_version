#!/bin/bash
# this script is for parallel the sample
# author: laojp
# time: 2023.05.08
# position: SYSUCC bioinformatic platform
# version: 1.0
# usage: 
	#  while read id; do 
	#   script ${id} &
	#   wait_Que $!
	#  done < <(ls ${file})
	#  [wait | finish_Que]

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
        PID=$1
        PushQue ${PID}
        while [[ $Nrun -ge $Nproc ]]; do
                sleep 10s
                ChkQue
        done
}
function finish_Que {
        while [[ $Nrun -gt 0 ]]; do
                echo "------$Que still running"
                sleep 10s
                ChkQue
        done
}
# 注意父进程中需要使用进程替换重定向文件输入，而不能使用管道符号，这样que与Nrun才不会在循环结束以后被清除

