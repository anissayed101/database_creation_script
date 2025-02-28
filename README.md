# Database Creation Automation Script for Cloudera CDP

This repository contains a fully automated script to create databases, users, and grant privileges for **Cloudera CDP services** across multiple database platforms.

The script ensures a **standardized naming convention**, supports **random or custom passwords**, and logs key actions for user convenience.

---

## 1️⃣ Overview

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

## 2️⃣ Supported Database Types

| Database Type | Required Client |
|---|---|
| Oracle | SQL*Plus (`sqlplus`) |
| MySQL | MySQL Client (`mysql`) |
| PostgreSQL | PostgreSQL Client (`psql`) |

---

## 3️⃣ Prerequisites

The following must be installed and accessible via `$PATH`:

- **Oracle:** `sqlplus` from Oracle Instant Client
- **MySQL:** `mysql` client
- **PostgreSQL:** `psql` client

Ensure the EC2 (or any machine running this script) has **network connectivity to the target databases**, and the necessary admin credentials are available.

---

## 4️⃣ Input - `db_config.csv`

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

