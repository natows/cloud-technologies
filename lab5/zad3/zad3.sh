#!/bin/bash

cat <<EOF > Dockerfile
ARG VERSION=3.10
FROM python:\${VERSION}
COPY myapp /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python","app.py"]
EOF

docker build -t my_python_app .
docker run --rm -p 5000:5000 my_python_app
