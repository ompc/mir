# program : gen-detail-md.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#    desc : 通过当日CSV流水生成当日MD详情页
#!/usr/bin/env bash

# MD文件输出路径
DETAIL_MD_OUT_DIR="../out/detail"

# 指定需要生成的账务日期${1},yyyy-mm-dd
TARGET_DATE=${1}
[ -z ${TARGET_DATE} ]&&TARGET_DATE=$(date +%Y-%m-%d)

# 源CSV文件
SOURCE_CSV_FILE="../data/${TARGET_DATE%-*}/${TARGET_DATE}/${TARGET_DATE}.csv"
[ ! -f ${SOURCE_CSV_FILE} ]&&exit


# 目标MD文件
DETAIL_MD_FILE="${DETAIL_MD_OUT_DIR}/${TARGET_DATE}.md"


## 生成页头
printf "## 当日积分排行榜：${TARGET_DATE}\n" > ${DETAIL_MD_FILE}

## 生成明细下载链接
printf "[积分明细下载](../../data/${TARGET_DATE%-*}/${TARGET_DATE}/${TARGET_DATE}.csv)\n" >> ${DETAIL_MD_FILE}
printf "[TT截图](./${TARGET_DATE}-PIC.html)\n" >> ${DETAIL_MD_FILE}

## 生成排行榜
echo -n "
排名|游戏玩家|积分|场次
:---:|---|---|---
" >> ${DETAIL_MD_FILE}

cat ${SOURCE_CSV_FILE} \
    | awk -F "," '{m[$2]+=$4;c[$2]++;}END{for(i in m)printf("%s,%0.2f,%s\n",i,m[i],c[i])}' \
    | sort -t ',' -nrk2,3 \
    | awk -F "," '{if(c!=$2$3){c=$2$3;n++;}printf("%s,%s,%s,%s\n",n,$1,$2,$3)}' \
    | awk -F "," '{if($1<=3){printf("![](https://raw.githubusercontent.com/ompc/mir/master/out/img/TOP%s.png)|**%s**|**%s**|**%s**\n",$1,$2,$3,$4)}else{printf("%s|%s|%s|%s\n",$1,$2,$3,$4)}}' \
    >> ${DETAIL_MD_FILE}

echo "${DETAIL_MD_FILE} was generated."

DETAIL_PIC_MD_FILE="${DETAIL_MD_OUT_DIR}/${TARGET_DATE}-PIC.md"
printf "## 当日积分TT截图：${TARGET_DATE}\n" > ${DETAIL_PIC_MD_FILE}
find ../data/${TARGET_DATE%-*}/${TARGET_DATE} -type f |grep -E "jp[e]?g"|while read file;do
    printf "![](../${file})\n" >> ${DETAIL_PIC_MD_FILE}
done


