ARG VERSION=3.10
ARG PORT=4000
FROM alpine:3.15

RUN apk add --no-cache python3 py3-pip 
WORKDIR /app
COPY app /app

VOLUME /app/data

ARG PORT
ENV PORT=${PORT}
RUN pip install -r requirements.txt

CMD ["python3","app.py"]
