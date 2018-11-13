#!/bin/bash

# Set parameters.  Change these to suit your environment.

version = "0.1"
targetroot="/var/www/testsite.co.uk"
base_url="https://www.testsite.co.uk/"

codeigniter_version="3.1.9"
bootstrap_version="4.1.3"
crud_version="master"

db_username="YOUR_USERNAME"
db_password="YOUR_PASSWORD"
db_name="YOUR_DB_NAME"

clear

# Check that the script is running as root. If not, then prompt for the sudo password and re-execute this script with sudo.

if [ "$(id -nu)" != "root" ]; then
    sudo -k
    pass=$(whiptail --backtitle "$brand Installer" --title "!! WARNING !! - codeigniter-setup $version" --passwordbox "This script WILL DELETE THE $targetroot DIRECTORY if it exists and will restart Apache.  This requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 70 3>&2 2>&1 1>&3-)
    exec sudo -S -p '' "$0" "$@" <<< "$pass"
    exit 1
fi

cd /var/www
rm -rf $targetroot
mkdir $targetroot
cd $targetroot

# Download and unzip the packages.

echo "Downloading CodeIgniter version $codeigniter_version.."
wget -q https://github.com/bcit-ci/CodeIgniter/archive/$codeigniter_version.zip --output-document=./codeigniter_$codeigniter_version.zip > /dev/null
echo "Downloading Bootstrap version $bootstrap_version.."
wget -q https://github.com/twbs/bootstrap/archive/v$bootstrap_version.zip --output-document=./bootstrap_v$bootstrap_version.zip
echo "Downloading Grocery CRUD version $crud_version.."
wget -q https://github.com/scoumbourdis/grocery-crud/archive/$crud_version.zip --output-document=./grocery_crud_$crud_version.zip
echo "Unzip all downloads.."
unzip -qq codeigniter_$codeigniter_version.zip
unzip -qq bootstrap_v$bootstrap_version.zip
unzip -qq grocery_crud_$crud_version.zip
rm *.zip

# Move CodeIgniter into the correct position.

echo "Setup CodeIgniter.."
mv ./CodeIgniter-$codeigniter_version/ ./public_html
mv ./public_html/application ./
mv ./public_html/system ./
mkdir -p ./public_html/assets
mkdir public_html/assets/css/
mkdir public_html/assets/js/

# Move GroceryCrud into the correct position.

echo "Setup Grocery CRUD.."
mv ./grocery-crud-master/assets/grocery_crud/ public_html/assets
mv ./grocery-crud-master/assets/uploads/ public_html/assets
mv ./grocery-crud-master/application/config/grocery_crud.php application/config/
mv ./grocery-crud-master/application/controllers/Examples.php application/controllers/
mv ./grocery-crud-master/application/libraries/*.php application/libraries/
mv ./grocery-crud-master/application/models/Grocery_crud_model.php application/models/
mv ./grocery-crud-master/application/views/example.php application/views/

rm public_html/contributing.md
rm public_html/license.txt
rm public_html/readme.rst
rm -rf grocery-crud-master/

# Move Bootstrap into the correct position.
echo "Setup Bootstrap.."
mv ./bootstrap-$bootstrap_version/dist/* ./public_html/assets
rm -rf ./bootstrap-$bootstrap_version
rm -rf ./public_html/tests

# Make backup copies of the configuration and index files..

cp ./public_html/index.php ./public_html/index.php.original
cp ./application/config/config.php ./application/config/config.php.original

search_for="$system_path = 'system';"
replace_with="$system_path = '$targetroot/system';"
sed -i "s#$search_for#$replace_with#g" "./public_html/index.php"

search_for="$system_path = 'application';"
replace_with="$system_path = '$targetroot/application';"
sed -i "s#$search_for#$replace_with#g" "./public_html/index.php"

# Configure CodeIgniter config files..

echo "Configuring CodeIgniter.."
search_for="\$config\['base_url'\] = '';"
replace_with="\$config\['base_url'\] = '$base_url';"
sed -i "s#$search_for#$replace_with#g" "./application/config/config.php"

search_for="\$config\['sess_save_path'\] = NULL;"
replace_with="\$config\['sess_save_path'\] = sys_get_temp_dir();"
sed -i "s#$search_for#$replace_with#g" "./application/config/config.php"

# Configure .htaccess for CodeIgniter..

echo "Configuring .htaccess in the root of CodeIgniter.."
su -c $'echo "RewriteEngine on" >> "$targetroot"public_html/.htaccess'
su -c $'echo "RewriteCond %{REQUEST_FILENAME} !-f" >> "$targetroot"public_html/.htaccess'
su -c $'echo "RewriteCond %{REQUEST_FILENAME} !-d" >> "$targetroot"public_html/.htaccess'
su -c $'echo "RewriteRule ^(.*)$ index.php/$1 [L]" >> "$targetroot"public_html/.htaccess'

# Configure database connection for CodeIgniter..

echo "Configuring database parameters in $targetroot/application/config/database.php"
sed -i s/"\$autoload\['libraries'\] = array();"/"\$autoload\['libraries'\] = array('database', 'session');"/g "$targetroot"/application/config/autoload.php
sed -i s/"'username' => '',"/"'username' => '$db_username',"/g "$targetroot"/application/config/database.php
sed -i s/"'password' => '',"/"'password' => '$db_password',"/g "$targetroot"/application/config/database.php
sed -i s/"'database' => '',"/"'database' => '$db_name',"/g "$targetroot"/application/config/database.php

# Set the permissions for the website installation..

echo "Set privs for $targetroot.."
su -c $"chown -R www-data:www-data "$targetroot""
su -c $"find "$targetroot" -type f -print0 | xargs -0 chmod 0664"
su -c $"find "$targetroot" -type d -print0 | xargs -0 chmod 0775"

# Restart Apache..

echo "Restart Apache web server.."
su -c $"service apache2 restart"

# Finished.

echo "Site should be available at "$base_url"public_html"
