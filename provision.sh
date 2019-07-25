required_vars=(
  APP_NAME
  NODE_VERSION
  POSTGRES_VERSION
  RUBY_VERSION
)

for var in "${required_vars[@]}"
do
  if [[ -z ${!var} ]]; then
    echo "$var is not set"
    exit
  fi
done



echo "-----> set locale"

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

sudo update-locale LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL LANG=$LANG LC_TYPE=$LC_TYPE



echo "-----> install apt packages"

sudo apt-get update --quiet
sudo apt-get install --yes --no-install-recommends --quiet \
  build-essential
  sqlite3 \
  libsqlite3-dev \
  tree
  2> /dev/null



echo "-----> install postgres"

# SEE: https://wiki.postgresql.org/wiki/Apt
sudo apt-get install --yes --quiet ca-certificates gnupg
curl --silent --show-error https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update --quiet
sudo apt-get install --yes --quiet postgresql-$POSTGRES_VERSION postgresql-contrib libpq-dev

sudo -u postgres createuser -s $USER

# Optional: enable trust auth method for PostgreSQL
#
# sudo bash -c "cat > /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf" <<EOL
# local all all trust
# host all all 127.0.0.1/32 trust
# host all all ::1/128 trust
# EOL
#
# sudo service postgresql restart

createdb "$APP_NAME"_development
createdb "$APP_NAME"_test
createdb "$APP_NAME"_production



echo "-----> install redis"

sudo apt-get install --yes --quiet redis-server
sudo systemctl enable redis-server.service
sudo systemctl restart redis-server.service



echo "-----> install elasticsearch"

sudo apt-get install --yes -qq default-jre apt-transport-https
curl --silent --show-error https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo add-apt-repository "deb https://artifacts.elastic.co/packages/7.x/apt stable main"
sudo apt-get update --quiet
sudo apt-get install --yes --quiet elasticsearch
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# Optional ElasticSearch configuration update
#
# sudo bash -c "cat > /etc/elasticsearch/elasticsearch.yml" <<EOL
# index.number_of_shards: 1
# index.number_of_replicas: 0
# network.bind_host: 0
# network.host: 0.0.0.0
# script.inline: on
# script.indexed: on
# http.cors.enabled: true
# http.cors.allow-origin: /https?:\/\/.*/
# EOL
#
# sudo bash -c 'echo "ES_HEAP_SIZE=64m" >> /etc/default/elasticsearch'
#
# sudo service elasticsearch restart



echo "-----> install nodejs"

curl --silent --show-error https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
sudo apt-get install --yes nodejs



echo "-----> install yarn"

sudo curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update --quiet
sudo apt-get install --yes --quiet yarn



if ! [ -x "$(command -v ruby-install)" ]; then
  echo "-----> install ruby-install"
  RUBY_INSTALL="ruby-install-0.7.0"
  cd
  curl --location --silent --show-error -o $RUBY_INSTALL https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
  tar -xzvf $RUBY_INSTALL
  cd $RUBY_INSTALL
  sudo make install
  cd
  rm -rf $RUBY_INSTALL*
fi



echo "-----> install ruby"

RUBIES_DIR=$HOME/.rubies

ruby-install --no-reinstall --cleanup --rubies-dir $RUBIES_DIR ruby $RUBY_VERSION

PATH=$RUBIES_DIR/ruby-$RUBY_VERSION/bin:$HOME/.bin$PATH

cat > ~/.gemrc <<EOL
---
gem: --no-ri --no-rdoc
benchmark: false
verbose: true
backtrace: true
EOL

gem update --system
gem install --force bundler



if ! [ -x "$(command -v micro)" ]; then
  echo "-----> install micro"
  mkdir -p ~/.bin
  cd ~/.bin
  curl --location --silent --show-error https://getmic.ro | bash
fi



if ! [ -x "$(command -v fd)" ]; then
  echo "-----> install fd"
  FD_DEB=~/fd.deb
  curl --location --silent --show-error -o $FD_DEB https://github.com/sharkdp/fd/releases/download/v7.3.0/fd-musl_7.3.0_amd64.deb
  sudo dpkg -i $FD_DEB
  rm -rf $FD_DEB
fi



echo "-----> update .bashrc"

cat >> ~/.bashrc <<EOL
export PATH=$PATH
export EDITOR=micro
alias l="exa --all --long --group-directories-first"
alias e="$EDITOR"
alias g="git status"
alias gl="git log --graph --decorate --pretty=oneline --abbrev-commit -n 10"
EOL



echo "-----> cleanup"

sudo apt autoremove --yes
sudo apt-get clean



echo "-----> report"

echo "ruby:          $(ruby --version)"
echo "gem:           $(gem --version)"
echo "bundler:       $(bundler --version)"
echo "yarn:          $(yarn --version)"
echo "node:          $(node --version)"
echo "psql:          $(psql --version)"
echo "redis:         $(redis-server --version)"
