# Kafka SSL Setup Guide

This guide provides a step-by-step process to set up SSL for Kafka, including the generation of keystore and truststore files and the creation of necessary credentials. This script is made for an Ubuntu OS, so you may need to adjust some commands for other operating systems.

## Prerequisites

- Java Development Kit (JDK) installed
- `keytool` command available
- Docker and Docker Compose installed

## Step 1: Create Directories for SSL Files and Logs

Create directories to store all SSL files and logs.

```sh
mkdir kafka_ssl
mkdir data
```

## Step 2: Create Your Own Private Certificate Authority (CA)

Generate a private certificate authority.

```sh
openssl req -new -newkey rsa:4096 -days 365 -x509 -subj "/CN=ca-kafka" -keyout kafka_ssl/ca-key -out kafka_ssl/ca-cert -nodes
```

## Step 3: Create Kafka Server Certificate and Store in Keystore

Generate a Kafka server certificate and store it in a keystore.

```sh
keytool -genkey -alias kafka-server-keys -keyalg RSA -keysize 2048 -keystore kafka_ssl/kafka.server.keystore.jks -validity 365 -storepass <password> -keypass <password> -dname "CN=<Common Name>,OU=<Organization Unit>,O=<Organization>,L=<City>,ST=<State>,C=<Country>" -storetype pkcs12
```

### Verify the Certificate

Verify the generated certificate.

```sh
keytool -list -v -keystore kafka_ssl/kafka.server.keystore.jks
```

## Step 4: Create Certificate Signing Request (CSR)

Create a CSR for the Kafka server certificate.

```sh
keytool -keystore kafka_ssl/kafka.server.keystore.jks -certreq -file kafka_ssl/cert-file -storepass <password> -keypass <password> -alias kafka-server-keys
```

## Step 5: Sign the CSR with the CA

Sign the CSR with your CA.

```sh
openssl x509 -req -CA kafka_ssl/ca-cert -CAkey kafka_ssl/ca-key -in kafka_ssl/cert-file -out kafka_ssl/cert-file-signed -days 365 -CAcreateserial -passin pass:<password>
```

### Verify the Signed Certificate

Verify the signed certificate.

```sh
keytool -printcert -v -file kafka_ssl/cert-file-signed
```

## Step 6: Import CA Certificate into Keystore

Import the CA certificate into the keystore.

```sh
keytool -keystore kafka_ssl/kafka.server.keystore.jks -alias CARoot -import -file kafka_ssl/ca-cert -storepass <password> -keypass <password> -noprompt
```

## Step 7: Import Signed CSR into Keystore

Import the signed CSR into the keystore and truststore.

```sh
keytool -keystore kafka_ssl/kafka.server.keystore.jks -import -file kafka_ssl/cert-file-signed -storepass <password> -keypass <password> -noprompt
keytool -keystore kafka_ssl/kafka.server.truststore.jks -import -file kafka_ssl/cert-file-signed -storepass <password> -keypass <password> -noprompt
```

## Step 8: Import CA Certificate into Truststore

Import the CA certificate into the truststore.

```sh
keytool -keystore kafka_ssl/kafka.server.truststore.jks -alias CARoot -import -file kafka_ssl/ca-cert -storepass <password> -keypass <password> -noprompt
```

## Step 9: Update Environment Variables in `config/.env` File

Update the environment variables in the `.env` file located in the `config` folder.

```plaintext
# Environment Specific Data
CLUSTER_ID=<cluster_id>
CERT_CN=<cert_common_name>
SSL_KEYSTORE_PASSWORD=<cert_pem_access_password>
SSL_TRUSTSTORE_PASSWORD=<cert_pem_access_password>
SSL_KEY_PASSWORD=<cert_pem_access_password>
KAFKA_USERNAME_INITIALIZE_ADMIN=<admin_username>
KAFKA_PASSWORD_INITIALIZE_ADMIN=<admin_password>
```

## Step 10: Adapt `server.properties` for Your Needs

The `server.properties` file is located in the `config` folder. Some variables are set using the `.env` file to simplify configuration, but you may need to update additional server settings based on your specific needs. Refer to the [Kafka documentation](https://kafka.apache.org/documentation/) for detailed information on properties.

## Step 11: Run the Kafka Server

Start the Kafka server using Docker Compose.

```sh
docker-compose up
```

## Troubleshooting

If you encounter any issues, check the following:

- Ensure all paths and filenames are correct.
- Verify that the keystore and truststore passwords match the credentials files.
- Check the Docker logs for any error messages.

This completes the setup for enabling SSL and SASL for Kafka. You should now have a secure Kafka setup with SSL encryption.