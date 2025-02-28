# Database Creation Automation Script for Cloudera CDP

This repository contains a fully automated script to create databases, users, and grant privileges for **Cloudera CDP services** across multiple database platforms.

The script ensures a **standardized naming convention**, supports **random or custom passwords**, and logs key actions for user convenience.

---

## 1. Overview

This script is designed to create databases for the following Cloudera services:
- Ranger
- Ranger KMS
- Hive Metastore
- Hue
- Oozie
- Streams Messaging Manager (SMM)
- Schema Registry
- Cloudera Manager Server
- Reports Manager

---

## 2. Supported Database Types

| Database Type | Required Client |
|---|---|
| Oracle | SQL*Plus (`sqlplus`) |
| MySQL | MySQL Client (`mysql`) |
| PostgreSQL | PostgreSQL Client (`psql`) |

---

## 3. Prerequisites

The following must be installed and accessible via `$PATH`:

- **Oracle:** `sqlplus` from Oracle Instant Client
- **MySQL:** `mysql` client
- **PostgreSQL:** `psql` client

Ensure the EC2 (or any machine running this script) has **network connectivity to the target databases**, and the necessary admin credentials are available.

---

## 4. Input - `db_config.csv`

The script reads configurations from a `db_config.csv` file. Each row defines **one database and user combination**.

### CSV File Structure

| Column | Description |
|---|---|
| DatabaseType | Oracle, MySQL, PostgreSQL |
| DatabaseName | Logical database name (ranger, hive, etc.) |
| Environment | Environment name (dev, test, prod) |
| Service | Service name (Ranger, Hue, etc.) |
| Company | Optional company name (BBI, etc.) |
| AdminConnString | Connection string (host:port/service for Oracle, host:port for MySQL/PostgreSQL) |
| AdminUser | Admin user (admin, root, postgres) |
| AdminPassword | Admin password |
| PasswordType | `random` or `custom` |
| Password | Required if `PasswordType=custom` |

---

### Sample CSV

```csv
DatabaseType,DatabaseName,Environment,Service,Company,AdminConnString,AdminUser,AdminPassword,PasswordType,Password
Oracle,ranger,dev,Ranger,BBI,database-1-oracle-19-qcb-test.cxue02aa6s1n.eu-north-1.rds.amazonaws.com:1521/DATABASE,admin,admin123,random,
Oracle,rangerkms,dev,RangerKMS,BBI,database-1-oracle-19-qcb-test.cxue02aa6s1n.eu-north-1.rds.amazonaws.com:1521/DATABASE,admin,admin123,custom,RangerKMS@123
```

---

## 5. Usage - Running the Script

### Command Format

```bash
sh configure_metadata_table.sh <db_config.csv> <DatabaseType>
```

### Examples

**Create only Oracle databases:**

```bash
sh configure_metadata_table.sh db_config.csv Oracle
```

**Create all databases:**

```bash
sh configure_metadata_table.sh db_config.csv ALL
```

If you forget to provide a database type, the script will **fail with a message** listing supported types.

---

## 6. Password Handling

- If `PasswordType=random`, the script will generate a **12-character password** with:
    - At least **1 uppercase letter**.
    - At least **1 lowercase letter**.
    - At least **1 number**.
    - At least **1 special character (`$`)**.

- **Generated passwords are printed only once and not stored anywhere.**

---

## 7. Sample Log Output

```
======================================================================
WARNING: This script will connect to the given databases and create the
specified databases, users, and grant privileges.

IMPORTANT: Generated passwords will be printed only once.
They will NOT be stored anywhere, so make sure to note them down.

If you lose the passwords, you will have to delete all the databases
and rerun this script again.
======================================================================

Do you want to continue? Type 'yes' to proceed, or anything else to cancel: yes

Database ranger_dev and user clouder_dev_BBI_Ranger created successfully.
Generated password for clouder_dev_BBI_Ranger: JgTH3DD8AY7T (Note this down, it won't be stored!)

Database rangerkms_dev and user clouder_dev_BBI_RangerKMS created successfully.
Generated password for clouder_dev_BBI_RangerKMS: RangerKMS@123 (Note this down, it won't be stored!)

...
======================================================================
All database and user creation operations are complete.
Remember: If you didn't note down the passwords, you'll have to delete
the databases and rerun the script!
======================================================================
```

---

## 8. Important Notes

- If no database type is provided, the script will **fail with an error** listing supported types.
- The script will not overwrite existing databases unless you manually drop them.
- For reruns with the same services, update either the **environment name** or the **database name** to create unique objects.

---

## 9. Security Note

**Passwords are only printed once during creation. They are never stored in files or logs.**  
If you lose them, you will need to:
- Drop the users manually.
- Rerun the script to recreate the users and generate new passwords.

---

## Contributions

Feel free to contribute! Fork the repo and raise a Pull Request with improvements.
Maintainer: *Anis Sayed*\
Company: *BBI*
