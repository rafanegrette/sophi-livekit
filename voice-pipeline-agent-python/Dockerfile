FROM python:3.12.9

# Install CA certificates for SSL/TLS connections
RUN yum update -y && yum install -y \
    ca-certificates \
    && update-ca-certificates \
    && yum clean all

WORKDIR /src
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
