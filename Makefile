.PHONY: help run build install_linters

help:
	@echo 'Available targets:'
	@echo '  make run'
	@echo '  make build'
	@echo '  make install_linters'

run: build
	./bin/run.sh $(DOMAIN)

build:
	docker build -t monitoring-worker -f Dockerfile .

install_linters:
	bin/install_linters_dependencies.sh
