#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt-get -o Acquire::ForceIPv4=true update -y
sudo apt-get -o Acquire::ForceIPv4=true upgrade -y
echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4


sudo apt install build-essential ruby-dev libxslt1-dev libmariadb-dev libxml2-dev zlib1g-dev imagemagick libmagickwand-dev curl gnupg2 bison libbison-dev libgdbm-dev libncurses-dev libncurses5-dev libreadline-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 -y
sudo apt install apache2 libapache2-mod-passenger -y
sudo systemctl enable --now apache2

gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
sudo usermod -aG rvm ubuntu
source /etc/profile.d/rvm.sh
rvm install 2.6.0
rvm --default use 2.6.0


sudo mkdir /opt/redmine/
sudo cp /opt/redmine/config/configuration.yml{.example,}
sudo cp /opt/redmine/public/dispatch.fcgi{.example,}
sudo cp /opt/redmine/config/database.yml{.example,}
sudo tee /opt/redmine/config/database.yml<<EOF
production:
  adapter: mysql2
  database: redminedb
  host: 35.180.21.38
  username: redmineuser
  password: "P@ssW0rD"
  # Use "utf8" instead of "utfmb4" for MySQL prior to 5.7.7
  encoding: utf8mb4
EOF
cd /opt/redmine
sudo gem install bundler


sudo bundle config set --local path 'vendor/bundle'
sudo bundle install
sudo bundle exec rake generate_secret_token
sudo RAILS_ENV=production bundle exec rake db:migrate
sudo RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data
for i in tmp tmp/pdf public/plugin_assets; do [ -d $i ] || mkdir -p $i; done
sudo chown -R root:root files log tmp public/plugin_assets
sudo chmod -R 755 /opt/redmine
sudo ufw allow 3000/tcp

sudo bash -c 'echo "@reboot root cd /opt/redmine/ && bundle exec rails server webrick -e production" >> /etc/crontab'

sudo systemctl restart apache2

