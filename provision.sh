export POSTGRES_DB_NAME="sampleapp"
export RUBY_VERSION="2.4.1"

echo -e "\n\n\n-----> Packages\n\n\n"

sudo apt-get install --yes python-minimal \
  python-pip \
  python-passlib \
  python-software-properties \
  language-pack-en-base \
  zlib1g-dev \
  build-essential \
  libssl-dev \
  libreadline-dev \
  libyaml-dev \
  libxml2-dev \
  libxslt1-dev \
  software-properties-common \
  libcurl3 \
  libcurl3-gnutls \
  libcurl4-openssl-dev \
  rsyslog-gnutls \
  libpq-dev \
  language-pack-en \
  imagemagick \
  qt5-default \
  libqt5webkit5-dev \
  ntp \
  git \
  curl \
  htop \
  tcl


echo -e "\n\n\n-----> install rbenv\n\n\n"

if [ -z "$RBENV_HOME" ]
then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export RBENV_HOME="$HOME/.rbenv"' >> ~/.bashrc
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
else
  echo 'rbenv already installed'
fi

echo -e "\n\n\n-----> install ruby\n\n\n"

source ~/.bashrc
rbenv --version
rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION
rbenv rehash
ruby --version

echo -e "\n\n\n-----> install bundler\n\n\n"

echo '---' > ~/.gemrc
echo 'gem: --no-ri --no-rdoc --no-document --suggestions' >> ~/.gemrc

gem install bundler
bundler --version

echo -e "\n\n\n-----> set environment vars for postgres\n\n\n"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LOCALE="en_US.UTF-8"

sudo /usr/sbin/locale-gen $LOCALE
sudo /usr/sbin/update-locale

echo -e "\n\n\n-----> install postgres\n\n\n"

sudo apt-get install --yes postgresql postgresql-contrib

echo "rewrite config"
sudo bash -c 'echo "local all all trust" > /etc/postgresql/9.5/main/pg_hba.conf'

sudo service postgresql restart

echo -e "\n\n\n-----> create postgres database\n\n\n"

createdb $POSTGRES_DB_NAME --username=postgres

echo -e "\n\n\n-----> install redis\n\n\n"

cd /tmp
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable
sudo make install
cd utils
sudo ./install_server.sh
sudo update-rc.d redis_6379 defaults
sudo rm -rf /tmp/redis-stable*

echo -e "\n\n\n-----> install elasticsearch\n\n\n"

cd /tmp
curl -O https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.1/elasticsearch-2.3.1.deb
sudo dpkg -i elasticsearch-2.3.1.deb
sudo systemctl enable elasticsearch.service
sudo rm -rf elasticsearch*

echo "rewrite config"
sudo bash -c 'echo "index.number_of_shards: 1" > /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'echo "index.number_of_replicas: 0" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'sudo echo "network.bind_host: 0" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'sudo echo "script.inline: on" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'sudo echo "script.indexed: on" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'sudo echo "http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'sudo echo "http.cors.allow-origin: /https?:\/\/.*/" >> /etc/elasticsearch/elasticsearch.yml'

# TODO: Don't add the line if it's already there
sudo bash -c 'echo "ES_HEAP_SIZE=64m" >> /etc/default/elasticsearch'

echo -e "\n\n\n-----> install nodejs\n\n\n"

cd /tmp
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install --yes nodejs

echo -e "\n\n\n-----> install yarn\n\n\n"

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --yes yarn
yarn --version

echo -e "\n\n\n-----> .bashrc\n\n\n"

echo "cd /app" >> ~/.bashrc
