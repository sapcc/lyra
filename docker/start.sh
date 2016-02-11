#!/bin/sh
set -e 

if ! rake db:abort_if_pending_migrations >/dev/null 2>&1; then
  if rake db:version 2>/dev/null; then
    echo Migrating database 
    rake db:migrate
  else
    echo Initializing database 
    rake db:setup
  fi 
fi

exec puma -C config/puma.rb 
