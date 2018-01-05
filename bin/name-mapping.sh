# program : name-mapping.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#    desc : 对指定名字进行修正,返回映射字典中的正确名字
#!/usr/bin/env bash

# 名字映射文件${1}指定
NAME_MAPPING_FILE=${1}

# 如果名字映射文件不存在,那就算了
[ ! -f ${NAME_MAPPING_FILE} ]&& cat

# 尝试进行名字映射
while read name;do
    mapping_name=$(grep "${name}=" ${NAME_MAPPING_FILE}|tail -1|awk -F "=" '{print $2}')
    if [[ ! -z ${mapping_name} ]]; then
        echo ${mapping_name}
    else
        echo ${name}
    fi
done