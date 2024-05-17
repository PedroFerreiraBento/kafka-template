# Kafka SSL Setup Guide

This guide provides a step-by-step process to set up SSL for Kafka, including the generation of keystore and truststore files and the creation of necessary credentials.

## Prerequisites

- Java Development Kit (JDK) installed
- `keytool` command available
- Docker and Docker Compose installed

## Step 1: Create a Directory for SSL Files

Create a directory to store all the SSL files.

```sh
mkdir kafka_ssl
```

## Step 2: Create own private Certificate Authority (CA)
```sh
openssl req -new -newkey rsa:4096 -days 365 -x509 -subj "/CN=ca-kafka" -keyout kafka_ssl/ca-key -out kafka_ssl/ca-cert -nodes
```

## Step 3: Create Kafka Server Certificate and store in KeyStore

```sh
keytool -genkey -alias kafka-server-keys -keyalg RSA -keysize 2048 -keystore kafka_ssl/kafka.server.keystore.jks -validity 365 -storepass <password> -keypass <password> -dname "CN=<Common Name>,OU=<Organization Unit>,O=<Organization>,L=<City>,ST=<State>,C=<Country>" -storetype pkcs12
```

### verify certificate

```sh
keytool -list -v -keystore kafka_ssl/kafka.server.keystore.jks
```

## Step 4: Create Certificate signed request (CSR)
```sh
keytool -keystore kafka_ssl/kafka.server.keystore.jks -certreq -file kafka_ssl/cert-file -storepass <password> -keypass <password> -alias kafka-server-keys
```

## Step 5: Get CSR Signed with the CA
```sh
openssl x509 -req -CA kafka_ssl/ca-cert -CAkey kafka_ssl/ca-key -in kafka_ssl/cert-file -out kafka_ssl/cert-file-signed -days 365 -CAcreateserial -passin pass:<password>
```
### verify certificate

```sh
keytool -printcert -v -file kafka_ssl/cert-file-signed
```

## Step 6:  Import CA certificate in KeyStore
```sh
keytool -keystore kafka_ssl/kafka.server.keystore.jks -alias CARoot -import -file kafka_ssl/ca-cert -storepass <password> -keypass <password> -noprompt
```

## Step 7:  Import Signed CSR In KeyStore
```sh
keytool -keystore kafka_ssl/kafka.server.keystore.jks -import -file kafka_ssl/cert-file-signed -storepass <password> -keypass <password> -noprompt
keytool -keystore kafka_ssl/kafka.server.truststore.jks -import -file kafka_ssl/cert-file-signed -storepass <password> -keypass <password> -noprompt
```

## Step 8:  Import CA certificate In TrustStore
```sh
keytool -keystore kafka_ssl/kafka.server.truststore.jks -alias CARoot -import -file kafka_ssl/ca-cert -storepass <password> -keypass <password> -noprompt
```

## Step 9: Start the Kafka and Zookeeper Services
Finally, start the Kafka and Zookeeper services using Docker Compose. Use the command from your selected environment.

```sh
make init_development
make init_staging
make init_production
```

## Troubleshooting
If you encounter any issues, check the following:

- Ensure all paths and filenames are correct.
- Verify that the keystore and truststore passwords match the credentials files.
- Check the Docker logs for any error messages.

This completes the setup for enabling SSL for Kafka. You should now have a secure Kafka setup with SSL encryption.