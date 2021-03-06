#!/bin/bash

WORK_DIR="../"
CURRENT_DATE=$(date +%Y-%m-%d)

cat guild.ids|while read gid;do
	mkdir -p ${WORK_DIR}/backup/${gid}/
	curl -sLk "http://47.94.203.49:8080/export/guild/${gid}" \
		 | gzip > ${WORK_DIR}/backup/${gid}/${gid}_${CURRENT_DATE}.gz \
		&& echo "backup ${gid} at ${CURRENT_DATE} success." \
		|| echo "backup ${gid} at ${CURRENT_DATE} failed." >> /dev/stderr
done

cd ${WORK_DIR} 
git add * \
	&& git commit * -m "backup for ${CURRENT_DATE}" \
	&& git push \
	&& echo "backup for ${CURRENT_DATE} success." \
	|| echo "backup for ${CURRENT_DATE} failed."
cd -
