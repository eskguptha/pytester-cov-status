FROM python:3
RUN python -m pip install --upgrade pip
RUN pip install fastapi coverage json-logging gunicorn autopep8 pylint pytest requests pytest-cov pytest-mock python-dotenv pytest-bdd 
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
