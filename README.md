# Vagrant configuration for Rails development environment

Will install:

- Ubuntu Xenial 16.04
- rbenv
- rbenv-build
- Ruby
- PostgreSQL
- Redis
- ElasticSearch
- NodeJS
- Yarn
- Bundler

Rails app setup after first log in (assuming Vagrant file is in you project root):

``` bash
cd /app
bundle install
bundle exec rails db:drop --trace
bundle exec rails db:create --trace
bundle exec rails db:migrate --trace
bundle exec rails db:seed --trace
```

Just in case, this is how you install ruby from sources, with `rbenv` and `ruby-build`:

``` bash
echo "-----> install rbenv"

git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

cat >> ~/.bashrc <<EOL
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "\$(rbenv init -)"
EOL

export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"



echo "-----> install ruby with rbenv"

rbenv install 2.4.1
rbenv global 2.4.1
```
