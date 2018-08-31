row_count=0     #有效数据的个数

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
  rm -f output/changeid_"${date}".txt
}

#从info.json文件中读入数据
read_file(){
  echo "以下是${date}之后每个change的活动时间和包含的patch set的数量-----" >> output/changeid_"${date}".txt
  timestamp=$(get_timestamp "${1}")
  #设置一个计数器
  counter=0
  while read line #从info.json逐行读入数据(每行都是一个project)
  do
    let counter++
    #获取change-id
    change_id=$(echo ${line} | grep -Po '"id":"[a-zA-Z0-9]*"' | grep -Po ':"[a-zA-Z0-9]*"' | grep -Po '[a-zA-Z0-9]*')
    
    #获取patch_的数量
    number_list=($(echo ${line} | grep -Po '"patchSets":\[.*\]' | grep -Po '{"number":[0-9]*' | grep -Po '[0-9]*'))
    if [ ${#number_list[@]} -gt 0 ];then
    index=`expr ${#number_list[@]} - 1`
    patch_set_number=${number_list[${index}]}
    else
    patch_set_number=""
    fi

    #获取change的活动时间
    created_time_list=($(echo ${line} | grep -Po '"createdOn":[0-9]*' | grep -Po '[0-9]*'))
    last_updated_time_list=($(echo ${line} | grep -Po '"lastUpdated":[0-9]*' | grep -Po '[0-9]*'))
    if [[ ${#created_time_list[@]} -gt 0 && ${#last_updated_time_list[@]} -gt 0 ]];then
    created_time=${created_time_list[0]}
    last_updated_time=${last_updated_time_list[0]}
    alive_time=`expr ${last_updated_time} - ${created_time}`
    else 
    alive_time=""
    fi

    #如果时间不在2018-08-01之后，则跳过
    if [[ -z ${change_id} || -z ${patch_set_number} || -z ${alive_time} || ${created_time} -lt ${timestamp} ]]
    then
    continue
    fi
    let row_count++

    #处理change的活动时间格式
    day=`expr ${alive_time} / $((3600 * 24))`
    hour=`expr $((${alive_time} % $((3600 * 24)))) / 3600`
    minute=`expr $((${alive_time} % 3600)) / 60`
    second=`expr ${alive_time} % 60`
    
    #写出到文件
    echo "change-id:"${change_id}"   patchSet:"${patch_set_number}"   活动时间:"${day}"天"${hour}"小时"${minute}"分钟"${second}"秒" >> output/changeid_"${date}".txt
  done < input/data.json
  echo "sum change:"${row_count} >> output/changeid_"${date}".txt
}


main(){
  clean_space "${1}"
  read_file "${1}"
}

main "${1}"