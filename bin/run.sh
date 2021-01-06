#!/bin/bash
set -uo pipefail

env_dir="./env"
domain=${1-""}

if [ "${domain}" != "" ]; then
	env_path="${env_dir}/${domain}.env"

	if [ ! -e "${env_path}" ]; then
		echo "Requested config does not exist: ${env_path}"

		exit 1
	fi

	docker run -it --rm --env-file="${env_path}"  monitoring-worker

	exit
fi

for env_file in "${env_dir}"/*.env
do
	if [[ "$env_file" == "${env_dir}/example.env" ]]; then
		continue
	fi

	docker run -it --rm --env-file="$env_file"  monitoring-worker
done
