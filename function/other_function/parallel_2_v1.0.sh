# 这是实现可控并行的另一种方法
# 首先awk读取txt文件的每一行，并且输出""sh SplitNCigarReads_command.sh "$1"字符串（也就是命令字符串）
# 然后将命令字符串通过管道符的形式传递给xargs命令
# xargs命令
#   -i选项为从输入中读取每一个参数（每一行）替换为'{}'，在命令行中，用'{}'表示在哪里插入输入项
#   -P选项为并行运行最多max-procs个进程
# bash命令
#   -c选项用于在将字符串作为命令执行
# 效果：
#   1. 首先使用awk读取文件每一行，并且提取第一列的项目合并到输出的字符串中，得到多行含有命令的字符串
#   2. 使用xargs命令保证最多每一次同时读取10行字符串，并且传递给bash进行运行（作为一个进程内进行）
#   3. bash每运行完一次（进程结束），xargs就会再读取（提交新的进程）
awk '{print "sh SplitNCigarReads_command.sh "$1}' /data2/baoxq/HNC_ana/file_order.txt | xargs -i CMD -P 10 bash -c CMD
