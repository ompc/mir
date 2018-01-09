# program : gen-mrank-md.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#    desc : 通过本月CSV流水生成本月MD详情页
#!/usr/bin/env bash

# MD文件输出路径
MRANK_MD_OUT_DIR="../out/mrank"

# 本月
TARGET_MONTH=${1}

# 本月路径
TARGET_MONTH_DIR="../data/${TARGET_MONTH}"

if [[ -z ${TARGET_MONTH} ]]; then
    printf "${TARGET_MONTH_DIR} didn't exist.\n" >&2
    exit -1
fi

# 目标MD文件
MRANK_MD_FILE="${MRANK_MD_OUT_DIR}/${TARGET_MONTH}.md"

# 月终变动文件
MRANK_CHANGE_FILE="../data/${TARGET_MONTH}/change.csv"

## 生成页头
printf "## 本月积分排行榜：${TARGET_MONTH}\n" > ${MRANK_MD_FILE}


## 生成排行榜
echo -n "
排名|游戏玩家|月积分|月场次|月中变动|月终结余
---|---|---|---|---|---
" >> ${MRANK_MD_FILE}

find ${TARGET_MONTH_DIR} -type f -name "*.csv" -maxdepth 2\
    |while read file;do cat ${file};done\
    |awk -F "," '{m[$2]+=$4;c[$2]++;}END{for(i in m)print i","m[i]","c[i]}'\
    |sort -t ',' -nrk2,3\
    |awk -F "," '{if(c!=$2$3){c=$2$3;n++;}printf("%s,%s,%s,%s\n",n,$1,$2,$3)}'\
    |while read record;do

    # 排名
    m_top=$(echo "${record}"|awk -F "," '{print $1}')

    # 玩家名字
    player=$(echo "${record}"|awk -F "," '{print $2}')

    # 玩家月积分
    m_score=$(echo "${record}"|awk -F "," '{printf("%0.2f\n",$3)}')

    # 玩家月场次
    m_play_times=$(echo "${record}"|awk -F "," '{print $4}')

    # 月中变动积分
    m_change=0;
    if [[ -f ${MRANK_CHANGE_FILE} ]]; then
        m_change=$(grep ${player} ${MRANK_CHANGE_FILE}|awk -F "," 'BEGIN{s=0;}{s+=$2}END{printf("%0.2f\n",s)}')
    fi

    # 月底结余
    m_balance=$(echo ""|awk '{printf("%0.2f\n",(a+b))}' a=${m_score} b=${m_change})

    printf "%s,%s,%s,%s,%s,%s\n" ${m_top} ${player} ${m_score} ${m_play_times} ${m_change} ${m_balance}\
        | awk -F "," '{if($1<=3){printf("![](https://raw.githubusercontent.com/ompc/mir/master/out/img/TOP%s.png)|**%s**|**%s**|**%s**|%s|%s\n",$1,$2,$3,$4,$5,$6)}else{printf("%s|%s|%s|%s|%s|%s\n",$1,$2,$3,$4,$5,$6)}}' \
        >> ${MRANK_MD_FILE}

done


