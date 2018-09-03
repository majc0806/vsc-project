#发生异常，退出脚本
error(){
  export TOP_PID=$$
  trap 'exit 1' TERM
  kill -s TERM $TOP_PID

}

#获取输入日期的时间戳，用于限定查询日期
get_timestamp(){
  timestamp=0
  if [ -n "${1}" ]
  then
    timestamp=$(date -d "${1}" +%s)
    result=${?}
    test ${result} -eq 1 && error  
  else
    timestamp=0
  fi
  echo ${timestamp}
}

#获取输入的日期
get_date(){
  timestamp=$(get_timestamp "${1}")
  date=$(date -d @${timestamp}  "+%Y-%m-%d %X") 
  echo ${date}
}

#脚本开始之前清理工作空间
clean_space(){
  date=$(get_date "${1}")
  if [ ! -d "output/" ];then
    mkdir output
  fi
  rm -f output/invalid_change_"${date}".txt
}

read_file(){
  echo "以下是无效的patch------" >> output/invalid_change_"${date}".txt
  timestamp=$(get_timestamp "${1}")
  counter=0
  while read line;do
    #提取主题
    subject=$(echo ${line} | grep -Po '"subject":[ ]*"[Rr]evert')
    result=${?}
    if [ ${result} -eq 0 ];then
      change_id=$(echo ${line} | grep -Po '"id":"[a-zA-Z0-9]*"' | grep -Po ':"[a-zA-Z0-9]*"' | grep -Po '[a-zA-Z0-9]*')
    else
      continue
    fi
    
    #提取当前change的提交时间
    created_time_list=($(echo ${line} | grep -Po '"createdOn":[0-9]*' | grep -Po '[0-9]*'))
    created_time=${created_time_list[0]}
    
    #如果时间不在给定时间之后，则跳过
    if [[ -z ${created_time} || ${created_time} -lt ${timestamp} ]];then
      continue
    fi
    let counter++
    
    #写出到文件
    echo "change-id:"${change_id} >> output/invalid_change_"${date}".txt
  done < input/data.json
  echo "sum change:"${counter} >> output/invalid_change_"${date}".txt
}

main(){
  clean_space "${1}"
  read_file "${1}"
}

main "${1}"