#!/bin/bash
set -uo pipefail

function run_container() {
	docker run --rm --env-file="$1" -e MONITORING_WORKER_ID="get-worker-id-from-configuration-service" -v "$2":"$3" "$4"
}

env_dir="./env"
domain=${1-""}
logs_path="$(pwd)/log"
container_logs_path="/home/user/log"
monitoring_worker_image="gruz0/monitoring-worker:latest"

if [ "${domain}" != "" ]; then
	env_file="${env_dir}/${domain}.env"

	if [ ! -e "${env_file}" ]; then
		echo "Requested config does not exist: ${env_file}"

		exit 1
	fi

	run_container "$env_file" "$logs_path" "$container_logs_path" "$monitoring_worker_image"

	exit
fi

for env_file in "${env_dir}"/*.env
do
	if [[ "$env_file" == "${env_dir}/example.env" ]]; then
		continue
	fi

	run_container "$env_file" "$logs_path" "$container_logs_path" "$monitoring_worker_image"
done
