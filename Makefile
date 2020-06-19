.PHONY: help install_linters

help:
	@echo 'Available targets:'
	@echo '  make install_linters'

install_linters:
	bin/install_linters_dependencies.sh
