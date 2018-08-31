 结合一下当前的学习情况，帮我完成一个数据统计的事情。

    当前项目里面只统计了inline comments的数量，这个数据只反映了code review 的情况，现在需要统计一下开发人员的代码提交情况、change的活动时间、有效change的数量～～


    主要数据包括一下几个内容：

    * 1、每个开发提交patch的merge数量、abondan数量及比例；

    * 2、每个project上的patch的merge数量、abondan数量及比例；

   

        3、一个patch的活动时间和patch set数量，从提交到merge或到abondan；

        4、revert的提交统计：一个patch已经merge，后又被revert掉并merge，也是无效patch。统计这种patch的活动时间。

   

    实现方式：

    1、通过gerrit query命令查询192.168.67.126 gerrit上branch:benisont-y-2.2-sta1295-main在八月份的提交情况；然后是这个分支上的所有情况。

    2、在http://192.168.67.39:9090/jenkins/view/Analysis/job/Gerrit-Query-Code-Report-Test/，这个jenkins job中写shell 脚本，并将统计结果用邮件发出来。。（脚本可以现在本地写好，然后再放到jenkins里面，比较有没有细微差别。）