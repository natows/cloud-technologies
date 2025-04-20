FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .  
RUN pip install -r requirements.txt
COPY server.py .
EXPOSE 3003
CMD ["python", "server.py"]  
