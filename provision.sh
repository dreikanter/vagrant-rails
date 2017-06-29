set -e
set -x

export POSTGRES_DB_NAME="sampleapp"
export RUBY_VERSION="2.4.1"
export DEPLOY_USER="vagrant"

set -e
set -x

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

sudo update-locale LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL LANG=$LANG LC_TYPE=$LC_TYPE

cd
sudo apt-get update --yes
sudo apt-get install --yes \
  language-pack-en \
  python-minimal \
  python-pip \
  python-passlib \
  zlib1g-dev \
  build-essential \
  libssl-dev \
  libreadline-dev \
  libyaml-dev \
  libxml2-dev \
  libxslt1-dev \
  software-properties-common \
  libcurl4-openssl-dev \
  libpq-dev \
  imagemagick \
  git \
  curl \
  htop \
  tcl \
  ntp \
  boxes

  # python-software-properties \
  # libcurl3 \
  # libcurl3-gnutls \
  # rsyslog-gnutls \
  # qt5-default \
  # libqt5webkit5-dev \

say "install rbenv"

# sudo -u $DEPLOY_USER rm -rf ~/.rbenv

if [ ! -d "$HOME/.rbenv" ]; then
  echo "Installing rbenv and ruby-build"

  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

else
  echo "Updating rbenv and ruby-build"

  cd ~/.rbenv
  git pull

  cd ~/.rbenv/plugins/ruby-build
  git pull
fi

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

if [ ! -d "$HOME/.rbenv/versions/$RUBY_VERSION" ]; then
  say "install ruby"

  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION

  say "set up gem"

  echo "---" > ~/.gemrc
  echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
  echo "benchmark: false" >> ~/.gemrc
  echo "verbose: true" >> ~/.gemrc
  echo "backtrace: true" >> ~/.gemrc

  gem update --system
  gem update

  say "install bundler"

  gem install bundler
  bundle config path vendor/bundle

  rbenv rehash
fi
echo "-----> install postgres"

sudo apt-get install --yes postgresql postgresql-contrib

echo "rewrite config"
sudo bash -c "cat > /etc/postgresql/9.5/main/pg_hba.conf" <<EOL
local all all trust
host all all 127.0.0.1/32 trust
host all all ::1/128 trust
EOL

sudo service postgresql restart



echo "-----> create postgres database"

createdb $POSTGRES_DB_NAME --username=postgres



cd
sudo curl --silent --show-error -O http://download.redis.io/redis-stable.tar.gz
tar -xzf redis-stable.tar.gz
cd redis-stable
sudo make install
cd utils
sudo ./install_server.sh
sudo update-rc.d redis_6379 defaults
cd
sudo rm -rf ./redis-stable*


echo "-----> install elasticsearch"

sudo apt-get install default-jre
cd
sudo curl --silent --show-error -O https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.1/elasticsearch-2.3.1.deb
sudo dpkg -i elasticsearch-2.3.1.deb
sudo systemctl enable elasticsearch.service

cd
sudo rm -rf ./elasticsearch*

echo "rewrite config"
sudo bash -c "cat > /etc/elasticsearch/elasticsearch.yml" <<EOL
index.number_of_shards: 1
index.number_of_replicas: 0
network.bind_host: 0
network.host: 0.0.0.0
script.inline: on
script.indexed: on
http.cors.enabled: true
http.cors.allow-origin: /https?:\/\/.*/
EOL

# TODO: Don't add the line if it's already there
sudo bash -c 'echo "ES_HEAP_SIZE=64m" >> /etc/default/elasticsearch'

###############################################################################

say "install nodejs"

cd
sudo curl --silent --show-error -L https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install --yes nodejs

###############################################################################

say "install yarn"

sudo curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --yes yarn

###############################################################################

say ".bashrc"

echo "cd /app" >> ~/.bashrc

###############################################################################

say "cleanup"

sudo apt autoremove --yes
sudo apt-get clean
cat /dev/null > ~/.bash_history && history -c && exit

###############################################################################

echo "rbenv:   $(rbenv --version)"
echo "ruby:    $(ruby --version)"
echo "bundler: $(bundler --version)"
echo "yarn:    $(yarn --version)"
echo "node:    $(node --version)"
echo "psql:    $(psql --version)"
echo "redis:   $(redis-server --version)"
