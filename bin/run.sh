#!/bin/bash
set -euo pipefail

for env_file in ./env/*.env
do
	if [[ "$env_file" == "./env/example.env" ]]; then
		continue
	fi

	docker run -it --rm --env-file="$env_file"  monitoring-worker
done
