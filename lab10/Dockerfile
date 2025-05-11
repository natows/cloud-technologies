FROM python:3.10-slim

ARG APP_NAME
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ${APP_NAME} app.py
    
CMD ["python", "app.py"]