#!/bin/bash
# Export environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Fill Server Properties with .env
exec ./fill_properties.sh

# Configure the log storage (Necessary for KRaft create the meta.properties file)
exec /opt/kafka/bin/kafka-storage.sh format --config /opt/kafka/config/server.properties --cluster-id ${CLUSTER_ID}

# Start the server with the server.properties file
exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/full-server.properties