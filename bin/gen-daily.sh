# program : mir-tt-gen-date-csv.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#    desc : 用于生成一个指定日期的账务流水CSV文件
#!/usr/bin/env bash

# 指定TT截图存放主目录
BASE_MIR_DIR="../data"

# 名字映射文件
NAME_MAPPING_FILE="../name-mapping.txt"

# 指定需要生成的账务日期${1},yyyy-mm-dd
TARGET_DATE=${1}
[ -z ${TARGET_DATE} ]&&TARGET_DATE=$(date +%Y-%m-%d)

# 获取指定账期
TARGET_PAYMENT=${TARGET_DATE%-*}

# 目标日期目录
TARGET_DATE_DIR=${BASE_MIR_DIR}/${TARGET_PAYMENT}/${TARGET_DATE}

# 目标日期账目流水CSV
TARGET_DATE_CSV_FILE=${TARGET_DATE_DIR}/${TARGET_DATE}".csv"

# 给指定的文件#{1}写入UTF8的BOM头
function writeUTF8BOM
{
    printf '\xEF\xBB\xBF' > ${1}
}

# 对指定名字${1}进行修正
# 返回映射字典中的正确名字
function name_mapping
{
    # 如果映射字典文件不存在就算了
    [ ! -f ${NAME_MAPPING_FILE} ]&& return ${1}

    local mapping_name=$(grep "${1}=" ${NAME_MAPPING_FILE}|tail -1|awk -F "=" '{print $2}')
    if [[ ! -z ${mapping_name} ]]; then
        echo "name ${1} mapping to ${mapping_name}"
        return ${mapping_name}
    else
        return ${1}
    fi
}

# 给指定的TT截图文件生成对应的CSV文件
# ${1} : 指定的TT截图文件
# 1. 生成的CSV存放路径和TT截图文件同级
# 2. 生成的CSV文件名和TT截图文件同名，但后缀为.cvs
# 3. CSV文件编码为GBK
# 4. 如果对应的CSV文件已经存在，则跳过
function gen_single_tt_csv
{
    local tt_img_file=${1}
    local tt_csv_file=${tt_img_file%.*}".csv"

    # 如果CSV文件已经生成，则主动忽略
#    if [[ -f ${tt_csv_file} ]]; then
#        echo "${tt_csv_file} already existed, skip..."
#        return
#    fi

    # 获取场次目录
    local play_times_dir=${tt_csv_file%/*}

    # 获取场次
    local play_times=${play_times_dir##*/}

    # 获取场次日期目录
    local play_times_date_dir=${play_times_dir%/*}

    # 获取场次日期
    local play_times_date=${play_times_date_dir##*/}

    # 获取本场次分数
    local play_times_score=$(echo ${play_times}|awk -F "_" '{print $2}')
    if [[ -z ${play_times_score} ]]; then
        echo "${tt_csv_file} didn't have play time score, skip..."
        return
    fi

    # 获取本场次分数类型:当前为积分(1)
    local play_times_score_type=1

    # 获取本场次分数变动缘由:当前为战斗奖励(1)
    local play_times_score_reason=1

    # CSV临时文件
    local _tmp_tt_csv_file=${tt_csv_file}".tmp"
    writeUTF8BOM ${_tmp_tt_csv_file}

    # 这里进行最重要的图像识别转换
    cat ${tt_img_file} \
        | ./mir-tt-dkp.sh \
            ${play_times_date} \
            ${play_times_score_type} \
            ${play_times_score} \
            ${play_times_score_reason} \
            ${NAME_MAPPING_FILE} \
        >> ${_tmp_tt_csv_file} \
        || rm -f ${_tmp_tt_csv_file}

    # 正式替换CSV的临时文件为正式CSV文件
    if [[ -f ${_tmp_tt_csv_file} ]]; then
        mv ${_tmp_tt_csv_file} ${tt_csv_file}
        echo "${tt_csv_file} was generated."
    else
        echo "${tt_csv_file} gen failed."
    fi

}

# 找到MIR目录下所有场次的TT截图，并生成对应的CSV文件
find ${TARGET_DATE_DIR} -type f -name "*.jpeg"|sort|while read file;do
    gen_single_tt_csv ${file}
done

# 对日期场次下所有的CSV文件进行场次合并
find ${TARGET_DATE_DIR} -type d -maxdepth 1|sed '1d'|while read play_times_dir;do

    play_times=${play_times_dir##*/}
    _tmp_TARGET_PLAY_TIMES_CSV_FILE=${play_times_dir}/${play_times}".tmp"
    TARGET_PLAY_TIMES_CSV_FILE=${play_times_dir}/${play_times}".csv"

    writeUTF8BOM _tmp_TARGET_PLAY_TIMES_CSV_FILE
    cat ${play_times_dir}/*.csv \
        | sed $'s/\xEF\xBB\xBF//g' \
        | sort|uniq -c|awk '$1==1{print $2}' \
        >> ${_tmp_TARGET_PLAY_TIMES_CSV_FILE}

    # 正式替换CSV的临时文件为正式CSV文件
    if [[ -f ${_tmp_TARGET_PLAY_TIMES_CSV_FILE} ]]; then
        rm ${play_times_dir}/*.csv
        mv ${_tmp_TARGET_PLAY_TIMES_CSV_FILE} ${TARGET_PLAY_TIMES_CSV_FILE}
        echo "${TARGET_PLAY_TIMES_CSV_FILE} was generated."
    else
        echo "${TARGET_PLAY_TIMES_CSV_FILE} gen failed."
    fi

done

# 对日期下所有场次CSV文件进行合并
_tmp_TARGET_DATE_CSV_FILE=${TARGET_DATE_CSV_FILE}".tmp"
rm -f ${TARGET_DATE_CSV_FILE} \
    && rm -f ${_tmp_TARGET_DATE_CSV_FILE} \
    && writeUTF8BOM ${_tmp_TARGET_DATE_CSV_FILE} \
    && find ${TARGET_DATE_DIR} -type f -name "*.csv"|while read file;do
        cat ${file} \
        | sed $'s/\xEF\xBB\xBF//g' \
        >> ${_tmp_TARGET_DATE_CSV_FILE}
    done

# 正式替换CSV的临时文件为正式CSV文件
if [[ -f ${_tmp_TARGET_DATE_CSV_FILE} ]]; then
    mv ${_tmp_TARGET_DATE_CSV_FILE} ${TARGET_DATE_CSV_FILE}
    echo "${TARGET_DATE_CSV_FILE} was generated."

    # 生成MD
    ./gen-daily-md.sh ${TARGET_DATE}

else
    echo "${TARGET_DATE_CSV_FILE} gen failed."
fi
