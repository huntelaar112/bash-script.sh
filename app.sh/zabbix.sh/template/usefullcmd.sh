# dump db
mysqldump -u db_user -p database_name > database_name.sql

# dump all db
mysqldump -u root -p --all-databases > all_databases.sql

# dump all, sperate file
for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    mysqldump $DB > "$DB.sql";
done

#create user
CREATE USER 'mysql_user'@'%' IDENTIFIED BY 'password';
# create new user with privileges
GRANT ALL PRIVILEGES ON *.* TO 'db_user'@'localhost' IDENTIFIED BY 'P@s$w0rd123!';
GRANT ALL PRIVILEGES ON *.* TO 'mysql_user'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;

# create db
CREATE DATABASE db_name;