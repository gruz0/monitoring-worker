#!/bin/bash
set -euo pipefail

cp bin/pre-commit .git/hooks/pre-commit
gem install rubocop rubocop-rspec rubocop-performance bundle-audit
