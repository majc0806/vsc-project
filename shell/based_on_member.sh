member_list=()  #成员列表
merged=()       #被Merge的change
abandoned=()    #被Abandon的change
row_count=0     #有效数据的个数(即json文件中最后一行中的rowCount)，用于最后校验和

#发生异常，退出脚本
error(){
  export TOP_PID=$$
  trap 'exit 1' TERM
  kill -s TERM $TOP_PID

}

get_data(){
  ssh -p 29418 majc0806@192.168.67.126 gerrit query --format=JSON branch:benisont-y-2.2-sta1295-main  > input/data.json
}

#脚本开始之前清理工作空间
clean_space(){
  rm -rf output
  rm -rf input
  mkdir output
  mkdir input
}

#改变状态数组，参数1为status，参数2为成员数组当前索引
#标识位为true时，表示Merged；false表示Abandoned
change_status(){
  echo "status改变索引的位置："${2}
  if [ ${1} == "MERGED" ] #此时Merged+1
  then
    let merged[${2}]++
    #如果此处的元素为空，置0
    if [ -z ${abandoned[${2}]} ]
    then
    abandoned[${2}]=0
    fi
  elif [ ${1} == "ABANDONED" ]    #此时ABANDONED+1
  then
    let abandoned[${2}]++
    #如果此处的元素为空，置0
    if [ -z ${merged[${2}]} ]
    then
    merged[${2}]=0
    fi
  else     #异常
    error
  fi
}

#从info.json文件中读入数据
read_file(){
  while read line #从info.json逐行读入数据(每行都是一个project)
  do
    counter=0       #计数器
    #提取每行的email(用来代替人名)
    email=$(echo ${line} | grep -Po '"owner":{.*?"email":".*?"' | grep -Po '[a-z0-9]*@.*?\.com')
    #提取每行的状态(ABANDONED或是MERGED)
    status=$(echo ${line} | grep -Po '"status":"[A-Z]*"' | grep -Po '[A-Z]*')
    #提取当前change的提交时间
    create_time=$(echo ${line} | grep -Po '"createdOn":[0-9]*' | grep -Po '[0-9]*')
    
    #如果时间不在2018-08-01之后，则跳过
    if [[ -z ${create_time} || ${create_time} -lt 1533052800 ]]
    then
    continue
    fi
    let row_count++

    echo ${email}" "${status}" "${row_count}
    
    flag=true  #设置一个标识位
    for member in ${member_list[@]}
    do
      let counter++
      if [ "${email}" == "${member}" ]
      then
        flag=false
        let counter--
        change_status ${status} ${counter}
        break
      fi
    done
    
    if ${flag}
    then
      member_list[${counter}]=${email}
      change_status ${status} ${counter}
    fi
  done < input/data.json
}

#将结果写出到文件中
write_out(){
  if $(check_info)
  then
    echo "以下是基于每个开发者的change-----" >> output/august
    for ((i=0;i<${#member_list[@]};i++))
    do
        echo ${member_list[${i}]}"   Abandoned:${abandoned[${i}]}   Merged:${merged[${i}]}" >> output/august
    done

    echo "sum change:"${row_count} >> output/august
    echo -e "sum member:"${#member_list[@]}"\n" >> output/august
  else
    error
  fi
}

#检查处理后的结果是否符合规则
check_info(){
  flag1=false;flag2=false
  #检验三个数组的长度是否一致(如果不出异常应该是一致的)
  if [[ ${#member_list[@]} -eq ${#merged[@]} && ${#merged[@]} -eq ${#abandoned[@]} ]]
  then
  flag1=true
  fi
  
  #检验所有的Merge和Abandon数量的和是否是rowCount
  sum=0

  for a in ${abandoned[@]}
  do
    let sum+=${a}
  done
  
  for m in ${merged[@]}
  do
    let sum+=${m}
  done
  
  if [ ${sum} -eq ${row_count} ]
  then
    flag2=true  
  fi

  #两个条件均满足则返回true
  if ${flag1} && ${flag2}
  then
    echo true
  fi
}

main(){
  clean_space
  get_data
  read_file
  write_out
}

main