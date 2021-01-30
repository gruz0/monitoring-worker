run: build-container
	@./bin/run.sh $(DOMAIN)

build-container:
	@docker build -t gruz0/monitoring-worker . > /dev/null

install_linters:
	bin/install_linters_dependencies.sh

.PHONY: run build-container install_linters
