#!/bin/sh
# Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ENSEMBL_VERSION=$1
TEST_ENV=$2
if [ -z "$ENSEMBL_VERSION" ]; then
  echo 'Cannot find the API version. Make sure this has been given to the script' >2
  exit
fi

# Install APT dependencies
apt-get clean
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates main restricted' >> /etc/apt/sources.list
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates universe' >> /etc/apt/sources.list
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates multiverse' >> /etc/apt/sources.list
apt-get update
apt-get install -y git vim
apt-get install -y libxml2-dev
apt-get install -y cpanminus libxml-libxml-perl libxml-simple-perl libxml-writer-perl
apt-get install -y libdbi-perl libdbd-mysql-perl
apt-get install -y build-essential
apt-get install -y libtest-differences-perl libtest-json-perl libtest-xml-simple-perl
apt-get install -y wget
apt-get install -y libz-dev
apt-get install -y bgzip2
# Clean up
apt-get clean

# Installing MySQL for development purposes. Also putting in an ro & rw user
if [ -n "$TEST_ENV" ]; then

  apt-get install -y python-software-properties
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
  add-apt-repository 'deb http://mirrors.coreix.net/mariadb/repo/10.0/ubuntu precise main'

  apt-get update
  USR=${MYSQL_USER:-root}
  PASSWD=${MYSQL_PASSWORD:-vagrant}
  echo "mysql-server mysql-server/root_password select "$PASSWD | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again select "$PASSWD | debconf-set-selections
  apt-get install -y mariadb-server

  service mysql stop
  cp /settings/my.cnf /etc/mysql/my.cnf
  service mysql start

  /usr/bin/mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO '"$USR"'@'%' IDENTIFIED BY '"$PASSWD"' WITH GRANT OPTION; FLUSH PRIVILEGES"
  /usr/bin/mysql -uroot -pvagrant -e "CREATE USER 'ro'@'%'; GRANT SELECT ON *.* TO 'ro'@'%'; FLUSH PRIVILEGES"
  /usr/bin/mysql -uroot -pvagrant -e "CREATE USER 'rw'@'%'; GRANT ALL PRIVILEGES ON *.* TO 'rw'@'%'; FLUSH PRIVILEGES"

  apt-get clean
fi
