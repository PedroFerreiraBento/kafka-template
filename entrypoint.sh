#!/bin/bash
# Export environment variables from .env file
export $(grep -v '^#' .env | xargs)


# JAAS configuration for the broker's PLAIN mechanism

cat /opt/kafka/config/server.properties >> /opt/kafka/config/full-server.properties

# Substituir as variáveis de ambiente no arquivo de entrada
sed_command="sed"

# Para cada variável no arquivo .env, criar uma expressão sed
while IFS= read -r line
do
    # Ignorar linhas comentadas
    if [[ ! "$line" =~ ^# ]]; then
        var_name=$(echo $line | cut -d '=' -f 1)
        var_value=$(eval echo \$$var_name)
        sed_command+=" -e 's|\$$var_name|$var_value|g'"
    fi
done < ".env"
### reemplacing with .env values
# Executar o comando sed no arquivo de entrada e salvar no arquivo de saída
eval "$sed_command" "/opt/kafka/config/server.properties" > "/opt/kafka/config/full-server.properties"

/opt/kafka/bin/kafka-storage.sh format --config /opt/kafka/config/server.properties --cluster-id ${CLUSTER_ID}

exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/full-server.properties