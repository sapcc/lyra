#!/bin/sh
set -e

if [ -f "$ENV_FILE" ]; then
  echo Sourcing environment file "$ENV_FILE" ...
  . "$ENV_FILE"
fi

if rake db:version 2>/dev/null; then
  echo rake db:migrate
  rake db:migrate
else
  echo rake db:setup db:migrate
  rake db:setup db:migrate
fi
exec "$@"
