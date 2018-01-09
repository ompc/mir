# program : gen-mrank.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#    desc : 通过本月CSV流水生成本月所有日期的CSV/MD
#!/usr/bin/env bash

# 本月
TARGET_MONTH=${1}

# 本月路径
TARGET_MONTH_DIR="../data/${TARGET_MONTH}"

if [[ -z ${TARGET_MONTH} ]]; then
    printf "${TARGET_MONTH_DIR} didn't exist.\n" >&2
    exit -1
fi

find ${TARGET_MONTH_DIR} -type d -maxdepth 1|sed '1d'|sed 's/.*\///g'\
| while read f;do
    ./gen-daily.sh ${f}
done

./gen-mrank-md.sh ${TARGET_MONTH}
