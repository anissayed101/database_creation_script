#!/bin/bash

# Function to generate a random password
generate_password() {
    local pass=$(tr -dc 'A-Za-z0-9$' < /dev/urandom | fold -w 12 | head -n 1)
    echo "$pass"
}

# Function to show usage and fail
show_usage_and_exit() {
    echo "======================================================================"
    echo "ERROR: Missing required argument - database type."
    echo ""
    echo "Usage: $0 <database_config_file> <database_type>"
    echo ""
    echo "Available Database Types:"
    echo "    - Oracle"
    echo "    - MySQL"
    echo "    - PostgreSQL"
    echo "    - ALL (to run for all types)"
    echo ""
    echo "Example:"
    echo "    ./create_databases.sh db_config.csv Oracle"
    echo "    ./create_databases.sh db_config.csv ALL"
    echo "======================================================================"
    exit 1
}

# Check if required arguments are provided
if [[ $# -lt 2 ]]; then
    show_usage_and_exit
fi

CONFIG_FILE=$1
FILTER_DB_TYPE=$2  # Required (Oracle, MySQL, PostgreSQL, ALL)

# Warn if database type is invalid
VALID_TYPES=("Oracle" "MySQL" "PostgreSQL" "ALL")
if [[ ! " ${VALID_TYPES[*]} " =~ " ${FILTER_DB_TYPE} " ]]; then
    echo "======================================================================"
    echo "ERROR: Invalid database type: $FILTER_DB_TYPE"
    echo "Available types are: Oracle, MySQL, PostgreSQL, ALL"
    echo "======================================================================"
    exit 1
fi

# Warning Message
echo "======================================================================"
echo "WARNING: This script will connect to the given databases and create the"
echo "specified databases, users, and grant privileges."
echo ""
echo "IMPORTANT: Generated passwords will be printed only once."
echo "They will NOT be stored anywhere, so make sure to note them down."
echo ""
echo "If you lose the passwords, you will have to delete all the databases"
echo "and rerun this script again."
echo "======================================================================"
echo ""
read -p "Do you want to continue? Type 'yes' to proceed, or anything else to cancel: " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Operation canceled."
    exit 1
fi

# Process the CSV file
while IFS=',' read -r DB_TYPE DB_NAME ENV SERVICE COMPANY ADMIN_CONN ADMIN_USER ADMIN_PASS PWD_TYPE PWD; do
    # Skip commented lines
    [[ $DB_TYPE =~ ^#.* ]] && continue

    # Trim spaces from fields
    DB_TYPE=$(echo "$DB_TYPE" | xargs)
    DB_NAME=$(echo "$DB_NAME" | xargs)
    ENV=$(echo "$ENV" | xargs)
    SERVICE=$(echo "$SERVICE" | xargs)
    COMPANY=$(echo "$COMPANY" | xargs)
    ADMIN_CONN=$(echo "$ADMIN_CONN" | xargs)
    ADMIN_USER=$(echo "$ADMIN_USER" | xargs)
    ADMIN_PASS=$(echo "$ADMIN_PASS" | xargs)
    PWD_TYPE=$(echo "$PWD_TYPE" | xargs)
    PWD=$(echo "$PWD" | xargs)

    # If filter is not ALL, skip unwanted types
    if [[ "$FILTER_DB_TYPE" != "ALL" && "$DB_TYPE" != "$FILTER_DB_TYPE" ]]; then
        continue
    fi

    FULL_DB_NAME="${DB_NAME}_${ENV}"
    if [[ -n "$COMPANY" ]]; then
        USERNAME="clouder_${ENV}_${COMPANY}_${SERVICE}"
    else
        USERNAME="clouder_${ENV}_${SERVICE}"
    fi

    if [[ "$PWD_TYPE" == "random" ]]; then
        PWD=$(generate_password)
        echo "Generated password for $USERNAME: $PWD (Note this down, it won't be stored!)"
    fi

    echo "Creating database: $FULL_DB_NAME for $DB_TYPE..."

    case "$DB_TYPE" in
        MySQL)
            mysql -u"$ADMIN_USER" -p"$ADMIN_PASS" -h"${ADMIN_CONN%:*}" -P"${ADMIN_CONN##*:}" -e "
                CREATE DATABASE IF NOT EXISTS $FULL_DB_NAME;
                CREATE USER IF NOT EXISTS '$USERNAME'@'%' IDENTIFIED BY '$PWD';
                GRANT ALL PRIVILEGES ON $FULL_DB_NAME.* TO '$USERNAME'@'%';
                FLUSH PRIVILEGES;"
            ;;
        PostgreSQL)
            PGPASSWORD="$ADMIN_PASS" psql -h "${ADMIN_CONN%:*}" -p "${ADMIN_CONN##*:}" -U "$ADMIN_USER" -d postgres -c "
                CREATE DATABASE $FULL_DB_NAME;
                CREATE USER $USERNAME WITH PASSWORD '$PWD';
                GRANT ALL PRIVILEGES ON DATABASE $FULL_DB_NAME TO $USERNAME;"
            ;;
        Oracle)
    sqlplus -s "$ADMIN_USER/$ADMIN_PASS@$ADMIN_CONN" <<EOF > /dev/null
        CREATE USER $USERNAME IDENTIFIED BY "$PWD";
        GRANT CONNECT, RESOURCE TO $USERNAME;
        ALTER USER $USERNAME QUOTA UNLIMITED ON USERS;
EOF

    echo "Database ${FULL_DB_NAME} and user ${USERNAME} created successfully."
    echo "Generated password for ${USERNAME}: ${PWD} (Note this down, it won't be stored!)"
    echo ""
    ;;
         *)
            echo "Unsupported database type: $DB_TYPE"
            ;;
    esac

    echo "Database $FULL_DB_NAME and user $USERNAME created successfully."
done < "$CONFIG_FILE"

echo ""
echo "======================================================================"
echo "All database and user creation operations are complete."
echo "Remember: If you didn't note down the passwords, you'll have to delete"
echo "the databases and rerun this script!"
echo "======================================================================"

