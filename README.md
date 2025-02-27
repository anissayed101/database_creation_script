# database_creation_script
database_creation_script


How to Use the Updated Script
Run for All Databases (Default)
bash
Copy
Edit
./create_databases.sh db_config.csv
Run for Only MySQL
bash
Copy
Edit
./create_databases.sh db_config.csv MySQL
Run for Only PostgreSQL
bash
Copy
Edit
./create_databases.sh db_config.csv PostgreSQL
Run for Only Oracle
bash
Copy
Edit
./create_databases.sh db_config.csv Oracle


echo 'export PATH=/opt/oracle/product/19c/dbhome_1/bin:$PATH' >> ~/.bashrc
echo 'export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/opt/oracle/product/19c/dbhome_1/lib' >> ~/.bashrc
source ~/.bashrc

