get_data(){
  ssh -p 29418 192.168.67.126 gerrit query --format=JSON branch:benisont-y-2.2-sta1295-main  > input/data.json
}

main(){
  get_data
  bash based_on_member.sh ${1}
  bash based_on_project.sh ${1}
}

main ${1}