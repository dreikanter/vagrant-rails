# Vagrant configuration for Rails development environment

``` bash
cd /app
bundle install
bundle exec rails db:drop --trace
bundle exec rails db:create --trace
bundle exec rails db:migrate --trace
bundle exec rails db:seed --trace
```
