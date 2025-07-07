FROM python:3.12.9

ENV GCRYPT_DISABLE_FIPS=1

# Install CA certificates for SSL/TLS connections
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
