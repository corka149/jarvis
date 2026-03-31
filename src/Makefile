
# Define the path to your virtual environment
VENV := ../.venv/bin/activate

makemessages:
	source $(VENV) && python manage.py makemessages --locale=de --locale=pl --extension html

compilemessages:
	source $(VENV) && python manage.py compilemessages --locale=de --locale=pl
