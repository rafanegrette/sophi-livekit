FROM python:3.12.9

ENV GCRYPT_DISABLE_FIPS=1
ENV LIBGCRYPT_FORCE_FIPS_MODE=0

# Install CA certificates for SSL/TLS connections
# Install CA certificates for SSL/TLS connections
RUN GCRYPT_DISABLE_FIPS=1 LIBGCRYPT_FORCE_FIPS_MODE=0 apt-get update && \
    GCRYPT_DISABLE_FIPS=1 LIBGCRYPT_FORCE_FIPS_MODE=0 apt-get install -y ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

    
WORKDIR /src
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
