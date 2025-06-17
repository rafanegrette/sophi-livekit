FROM python:3.12.9-slim

WORKDIR /src
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
COPY .env.local .

RUN python src/main.py download-files

CMD ["python", "src/main.py", "start"]
