# JAAS configuration for the broker's PLAIN mechanism

cat /opt/kafka/config/server.properties >> /opt/kafka/config/full-server.properties

# Replace environment variables in the input file
sed_command="sed"

# For each variable in the .env file, create a sed expression
while IFS= read -r line
do
    # Ignore commented lines
    if [[ ! "$line" =~ ^# ]]; then
        var_name=$(echo $line | cut -d '=' -f 1)
        var_value=$(eval echo \$$var_name)
        sed_command+=" -e 's|\$$var_name|$var_value|g'"
    fi
done < ".env"
### replacing with .env values
# Execute the sed command on the input file and save to the output file
eval "$sed_command" "/opt/kafka/config/server.properties" > "/opt/kafka/config/full-server.properties"
