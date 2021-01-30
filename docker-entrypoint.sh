#!/bin/sh

stderr_log="./log/$SETTINGS__DOMAIN.stderr.log"

bundle exec ruby ./boot.rb 2>> "$stderr_log"
