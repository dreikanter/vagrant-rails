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

Rails app setup after first log in:

``` bash
cd /app
bundle install
bundle exec rails db:drop --trace
bundle exec rails db:create --trace
bundle exec rails db:migrate --trace
bundle exec rails db:seed --trace
```
