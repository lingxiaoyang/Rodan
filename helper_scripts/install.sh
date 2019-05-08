#!/bin/sh
set -o errexit
set -o nounset
set -o xtrace

##############################
# Installation steps for Travis
##############################
export ADMIN_USER=rodan
export ADMIN_PASS=rodan
export DJANGO_DEBUG_MODE=False
export DJANGO_SECRET_KEY=localdev
export DJANGO_MEDIA_ROOT=/rodan/data/
export DJANGO_ALLOWED_HOSTS=['*']
export DJANGO_ADMIN_URL=admin/
export RABBITMQ_URL=amqp://guest_user:guest_pass@rabbitmq:5672//
export RABBITMQ_DEFAULT_USER=guest_user
export RABBITMQ_DEFAULT_PASS=guest_pass
export DJANGO_RODAN_LOGFILE=rodan.log

# Redis
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_DB=0

sudo pip install redis
sudo redis-server /etc/redis/redis.conf --port 6379

# Postgres
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_DB=rodan
export POSTGRES_USER=rodan
export POSTGRES_PASSWORD=rodan
export POSTGRES_DATABASE_LOGFILE=database.log

sudo apt-get update -yqq
sudo /etc/init.d/postgresql stop
sudo apt-get install -yqq postgresql-9.3 postgresql-contrib-9.3 postgresql-plpython-9.3
sudo /etc/init.d/postgresql reload
sudo /etc/init.d/postgresql start

psql -c "CREATE USER rodan WITH PASSWORD 'rodan';" -U postgres
psql -c "ALTER USER rodan WITH createdb;" -U postgres
psql -c "ALTER USER rodan WITH superuser;" -U postgres
psql -c "ALTER USER travis WITH createdb;" -U postgres
psql -c "ALTER USER travis WITH superuser;" -U postgres
psql -c "CREATE DATABASE rodan;" -U postgres
psql -c "CREATE DATABASE travis;" -U postgres
psql -c "UPDATE pg_language SET lanpltrusted = true WHERE lanname = 'plpythonu';" -U postgres
psql -c "CREATE EXTENSION plpythonu;" -U postgres
psql -c 'GRANT ALL PRIVILEGES ON DATABASE "rodan" TO travis;' -U postgres
psql -c 'GRANT ALL PRIVILEGES ON DATABASE "rodan" TO rodan;' -U postgres
psql -c 'GRANT ALL PRIVILEGES ON DATABASE "travis" TO travis;' -U postgres
psql -c 'GRANT ALL PRIVILEGES ON DATABASE "travis" TO rodan;' -U postgres

cat << EOF | python manage.py shell

import os
from django.contrib.auth.models import User
print ("Checking if Django super user exists...")
if not User.objects.filter(username=os.getenv('ADMIN_USER')).exists():
    User.objects.create_superuser(os.getenv('ADMIN_USER'), '', os.getenv('ADMIN_PASS'))
    print ("Created new user.")

EOF

# Pil-Rodan
# Some unittests rely on specific filetypes to exist in the database.
cd ./rodan/jobs && git clone https://github.com/DDMAL/pil-rodan.git && cd ../..
