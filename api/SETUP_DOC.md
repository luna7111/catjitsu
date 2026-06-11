## Requirements
You need to have python3 installed

## Initial setup
1. setup and run virtual env (here called .venv) :

- `python3 -m venv .venv` creates the virtual environment
- `source .venv/bin/activate` starts the virtual environment
- `echo $PATH | grep venv | wc -l` checks that virtual environment is active in this shell instance

2. create project :

- `pip install -r requirements.txt` installs the needed packages into the virtual environment
- `django-admin startproject drinks .` starts the project in the provided address

3. start project and create basic database :

- `python manage.py runserver`
- `python manage.py migrate`

Done! You can access the server with the link provided in console at startup.

## Key files
- `urls.py` shows the available exposed urls
- `models.py` shows the existing classes
- `views.py` contains the available endpoints and their behaviour