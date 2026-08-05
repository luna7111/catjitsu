#!/usr/bin/env bash

python manage.py collectstatic --noinput
python manage.py migrate --noinput
if [ -n "$DJANGO_SUPERUSER_USERNAME" ]; then
    python manage.py createsuperuser --noinput || true
fi

python -m gunicorn --bind 0.0.0.0:8000 --workers 3 catjitsu_api.wsgi