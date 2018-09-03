#发生异常，退出脚本
error(){
  export TOP_PID=$$
  trap 'exit 1' TERM
  kill -s TERM $TOP_PID
}

start(){
  if [ ! -f "input/data.json" ];then
    get_data
  fi
  echo "正在处理数据------"
  bash based_on_member.sh "${1}"
  bash based_on_project.sh "${1}"
  bash based_on_change.sh "${1}"
  bash get_invalid_changes.sh "${1}"
}

get_data(){
  if [ ! -d "input/" ];then
    mkdir input
  fi
  echo "正在重新下载json文件"
  ssh -p 29418 192.168.67.126 gerrit query --format=JSON --patch-sets branch:benisont-y-2.2-sta1295-main  > input/data.json
  ssh -p 29418 192.168.67.126 gerrit query --format=TEXT --patch-sets branch:benisont-y-2.2-sta1295-main  > input/data.txt
  test ${?} -eq 0 && echo "下载完成"
}

check_arguments(){
  arg1="${1}"
  arg2="${2}"
  #两个参数都存在
  if [[ "${arg1}" && "${arg2}" ]];then
    timestamp=$(date -d "${1}" +%s)
    result=${?}
    if [[ ${result} -eq 0 && (${arg2} == "y" || ${arg2} == "n")]];then
      test ${arg2} == "y" && get_data
      start ${arg1}
    else
      echo "参数错误"
      error
    fi
  #只有一个输入参数
  elif [[ "${arg1}" && ! "${arg2}" ]];then
    date=$(echo "${arg1}" | grep -Po '^[0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}:[0-9]{2}:[0-9]{2}')
    result=${?}
    if [ ${result} -eq 0 ];then
      start "${date}"
      return
    fi
    if [ ${arg1} == "y" ];then
      get_data
      start
      return
    elif [ ${arg1} == "n" ];then
      start
    else
      echo "参数错误"
      error
    fi
  #没有输入参数
  else
    start
  fi
}

main(){
  check_arguments "${1}" "${2}"
  echo "done------"
}

main "${1}" "${2}"