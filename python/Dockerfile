FROM python:3.13-slim

WORKDIR /app

COPY python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY python/ .
COPY shared /shared

EXPOSE 5002

CMD ["python", "app.py"]
