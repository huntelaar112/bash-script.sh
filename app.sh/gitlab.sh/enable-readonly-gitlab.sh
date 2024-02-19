#!/bin/bash

echo "Set gitlab repo readonly..."
gitlab-rails runner "Project.all.find_each { |project| project.update!(repository_read_only: true) }"

echo "Create gitlab_read_only user..."
psqlscript="CREATE USER gitlab_read_only WITH password 'mypassword';
GRANT CONNECT ON DATABASE gitlabhq_production to gitlab_read_only;
GRANT USAGE ON SCHEMA public TO gitlab_read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gitlab_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO gitlab_read_only;
ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON TABLES TO gitlab_read_only;
ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON SEQUENCES TO gitlab_read_only;"

echo ${psqlscript}> /tmp/roscript.sql
sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql -h /var/opt/gitlab/postgresql gitlabhq_production -f /tmp/roscript.sql

echo "Get md5pass of gitlab_read_only and set to /etc/gitlab/gitlab.rb"
md5pass=$(echo "mypassword" | gitlab-ctl pg-password-md5 gitlab_read_only)
psqlInfo="postgresql['sql_user_password'] = '${md5pass}'\npostgresql['sql_user'] = \"gitlab_read_onl\""
echo -e ${psqlInfo}  >> /etc/gitlab/gitlab.rb

echo "Reconfigure gitlab..."
sudo gitlab-ctl reconfigure 3>/dev/null
echo "Restart psql..."
sudo gitlab-ctl restart postgresql