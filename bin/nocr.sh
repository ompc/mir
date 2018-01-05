# program : nocr.sh
#  author : oldmanpushcart@gmail.com
#    date : 2018-01-03
# version : 0.0.1
#!/usr/bin/env bash

# NOCR的缓存文件
NOCR_CACHE_FILE=${HOME}/.nocr.cache
touch ${NOCR_CACHE_FILE}

# 生成本次随机TOKEN,用于生成临时文件计算MD5
NOCR_TOKEN=$(date |head|cksum|sed 's/ //g')

# 本次NOCR请求的临时文件
NOCR_TEMP_IMG_FILE="/tmp/nocr.${NOCR_TOKEN}.tmp"


cat > ${NOCR_TEMP_IMG_FILE}
NOCR_IMG_FILE_MD5=$(cat ${NOCR_TEMP_IMG_FILE}|md5)
NOCR_IMG_FILE_CACHE_JSON=$(cat ${NOCR_CACHE_FILE}|awk '/^'${NOCR_IMG_FILE_MD5}'$/,/^}$/')

if [[ -z ${NOCR_IMG_FILE_CACHE_JSON} ]]; then
    _temp_nocr_json=$(cat ${NOCR_TEMP_IMG_FILE} |${JAVA_HOME}/bin/java -jar ../lib/nocr-1.0.0.jar)
    _temp_nocr_result=$(echo "${_temp_nocr_json}" | grep "\"words_result_num\":")
    if [[ ! -z "${_temp_nocr_result}" ]]; then
        echo -e "${NOCR_IMG_FILE_MD5}\n${_temp_nocr_json}" >> ${NOCR_CACHE_FILE}
    fi
    printf "%s\n" "${_temp_nocr_json}"
else
    printf "%s\n" "${NOCR_IMG_FILE_CACHE_JSON}" \
    |sed '1d'
fi

# 清理后事
rm -f ${NOCR_TEMP_IMG_FILE}
