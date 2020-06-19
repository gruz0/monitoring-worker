.PHONY: help dockerize build run install_linters

help:
	@echo 'Available targets:'
	@echo '  make dockerize'
	@echo '  make build'
	@echo '  make run'
	@echo '  make install_linters'

dockerize:
	docker-compose up --build

build:
	docker build -t monitoring-worker -f Dockerfile .

run:
	docker run -it --rm monitoring-worker

install_linters:
	bin/install_linters_dependencies.sh
