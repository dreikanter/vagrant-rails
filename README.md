# Vagrant configuration for Rails development environment

Will install:

- Ubuntu Server (19.04 LTS)
- Ruby (via [ruby-install](https://github.com/postmodern/ruby-install))
- PostgreSQL
- Redis
- ElasticSearch
- NodeJS
- Yarn

Set up:

``` bash
brew cask install virtualbox vagrant
vagrant up
```

Rails app setup after first log in (assuming Vagrant file is in you project root):

``` bash
cd /app
bundle install
yarn install
bundle exec rails db:drop db:create db:migrate db:seed --trace
```

Running Rails app server:

``` bash
rails s
```

Running [webpack-dev-server](https://github.com/webpack/webpack-dev-server):

``` bash
bin/webpack-dev-server
```
