# gerrit数据统计
# ssh -p 29418 majc0806@192.168.67.126 gerrit query --format=TEXT after:2018-08-01 branch:benisont-y-2.2-sta1295-main  > input/august.txt
# ssh -p 29418 majc0806@192.168.67.126 gerrit query --format=JSON after:2018-08-01 branch:benisont-y-2.2-sta1295-main  > input/august.json

ssh -p 29418 majc0806@192.168.67.126 gerrit query --format=TEXT branch:benisont-y-2.2-sta1295-main  > input/data.txt
ssh -p 29418 majc0806@192.168.67.126 gerrit query --format=JSON branch:benisont-y-2.2-sta1295-main  > input/data.json