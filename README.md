# codeigniter-setup
This script sets up CodeIgniter on Apache.  To get the most out of the script, you will need to create a database on MySQL and with that, a username and password.

## Instructions

1. Download the script, say to /tmp
2. Edit the script with your favourite text editor and adjust the settings for your environment in the top of the script.
3. The following items need editing.  Adjust them according to your environment.
```
targetroot="/var/www/example.co.uk"
base_url="https://www.example.co.uk/"

db_username="my_database_user"
db_password="secretpassword"
db_name="my_database"
```
4. Now mark the script as executable.
```
chmod +x /tmp/codeigniter.sh
```
5. Run the script.
```
/tmp/codeigniter.sh
```
The system will ask you for an admin password for sudo, so re-enter your login password for your user account.

The script will run and complete.  You will still need to create and apache configuration file for the new site and enable it.  That's for the next version of the script!

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
