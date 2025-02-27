#!/bin/bash

# Function to generate a random password
generate_password() {
    local pass=$(tr -dc 'A-Za-z0-9$' < /dev/urandom | fold -w 12 | head -n 1)
    echo "$pass"
}

# Warning message
echo "======================================================================"
echo "WARNING: This script will connect to the given database and create the"
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
    echo "Operation canceled. Exiting..."
    exit 1
fi

# Check if file argument is provided
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <database_config_file>"
    exit 1
fi

CONFIG_FILE=$1

# Read the file line by line, skipping comments
while IFS=',' read -r DB_TYPE DB_NAME ENV SERVICE COMPANY ADMIN_CONN ADMIN_USER ADMIN_PASS PWD_TYPE PWD; do
    # Skip comment lines
    [[ $DB_TYPE =~ ^#.* ]] && continue

    # Trim spaces (handle leading/trailing spaces)
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

    # Construct the database name
    FULL_DB_NAME="${DB_NAME}_${ENV}"
    
    # Construct the username
    if [[ -z "$COMPANY" ]]; then
        USERNAME="clouder_${ENV}_${SERVICE}"
    else
        USERNAME="clouder_${ENV}_${COMPANY}_${SERVICE}"
    fi

    # Generate password if needed
    if [[ "$PWD_TYPE" == "random" ]]; then
        PWD=$(generate_password)
        echo "Generated password for $USERNAME: $PWD (Note this down, it won't be stored!)"
    fi

    echo "Creating database: $FULL_DB_NAME for $DB_TYPE..."

    case $DB_TYPE in
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
            sqlplus -s "$ADMIN_USER/$ADMIN_PASS@$ADMIN_CONN" <<EOF
                CREATE USER $USERNAME IDENTIFIED BY "$PWD";
                GRANT CONNECT, RESOURCE TO $USERNAME;
                ALTER USER $USERNAME QUOTA UNLIMITED ON USERS;
EOF
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
echo "the databases and rerun the script!"
echo "======================================================================"

