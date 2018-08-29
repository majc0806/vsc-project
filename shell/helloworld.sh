#定义一个成员列表
member_list=()
a=0
cat info.json | while read line
do
  echo ${line} | grep -Po '"owner":{.*?"email":".*?"' | grep -Po '[a-z0-9]*@.*?\.com' >> temp.txt && let a++
  echo ${a}
done

touch user.txt

#去除重复email
while read line
do
  while read inline
  do
    if [ -z "${inline}" ]
    then
    echo "something"
    fi
    if [ ${line} != ${inline} ]
    then
    echo ${line} >> user.txt
    break
    fi
  done < user.txt
done < temp.txt