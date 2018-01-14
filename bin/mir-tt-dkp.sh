# program : mir-tt-dkp.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#!/usr/bin/env bash

PREFIX_WORDS="腾讯";

# 第一个参数为目标日期:YYYY-MM-DD
CHANGE_DATE=${1}

# 第二个参数为分数变动类型项
CHANGE_TYPES=([1]="积分" [2]="烽火标" [3]="金币" [4]="元宝" [5]="人民币")
CHANGE_TYPE=${CHANGE_TYPES[${2}]}

# 第三个参数为分数变动的值:整数
CHANGE_VALUE=${3}

# 第三个参数为分数变动缘由
CHANGE_REASONS=([1]="战斗奖励" [2]="团队贡献" [3]="纪律违规" [4]="积分兑换" [5]="其他备注")
CHANGE_REASON=${CHANGE_REASONS[${4}]}

# 名字映射文件
NAME_MAPPING_FILE=${5}

cat|./nocr.sh|grep -Eo "{\"words\": \"[^:]*"${PREFIX_WORDS}":[^}]*}" \
    | awk '{print substr($0,12)}' \
    | awk '{print substr($0,0,length($0)-2)}' \
    | awk -F ":" '{print $2}' \
    | grep -vE "送给|(退出|进入)了|(下|上)线了|(下|上)麦" \
    | sed 's/,//g' \
    | ./name-mapping.sh ${NAME_MAPPING_FILE} \
    | sort \
    | uniq \
    | awk '{printf("%s,%s,%s,%s,%s\n", c_data, $0, c_type, c_value, c_reason)}' \
        c_data=${CHANGE_DATE} \
        c_type=${CHANGE_TYPE} \
        c_value=${CHANGE_VALUE} \
        c_reason=${CHANGE_REASON}
