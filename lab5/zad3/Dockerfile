ARG VERSION=3.10
FROM python:${VERSION}
COPY myapp /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python","app.py"]
