# codeigniter-setup
This script sets up CodeIgniter on Apache.  To get the most out of the script, you will need to create a database on MySQL and with that, a username and password.

## Instructions

1. Download the script.
2. Edit the script with your favourite text editor and adjust the settings for your environment in the top of the script.
3. The following items need editing..
```
targetroot="/var/www/example.co.uk"
base_url="https://www.example.co.uk/"

db_username="my_database_user"
db_password="secretpassword"
db_name="my_database"
```
Once these items have been edited

## Creating a MySQL database

Here's how to create a basic database on MySQL.

1. In a command shell, connect to the database using the command below and use the root password when prompted.
```
mysql -u root -p
```
2. Now create the database and password for it, using the commands below.
```
CREATE database my_database;
USE my_database;
GRANT ALL ON *.* TO 'my_database_user'@'localhost';
DROP USER 'my_database_user'@'localhost';
CREATE USER 'my_database_user'@'localhost' IDENTIFIED BY 'secretpassword';
GRANT ALL ON my_database.* TO 'my_database_user'@'localhost';
FLUSH PRIVILEGES;
```
Once done, your database is ready for use.
