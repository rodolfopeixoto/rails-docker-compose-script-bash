#!/bin/bash
echo "##################################"
echo "          Task Automaton          "
echo "##################################"

echo -n "Enter the name of your app: "
read myapp
mkdir $myapp
cd $myapp
touch Dockerfile

echo "FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /$myapp
WORKDIR /$myapp
ADD Gemfile /$myapp/Gemfile
ADD Gemfile.lock /$myapp/Gemfile.lock
RUN bundle install
ADD . $myapp
RUN bundle install
" > Dockerfile

touch Gemfile
echo "source 'https://rubygems.org'
gem 'rails', '5.0.0.1'
" > Gemfile

touch Gemfile.lock

touch docker-compose.yml

echo "version: '3'
services:
  db:
    image: postgres
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/$myapp
    ports:
      - "3000:3000"
    depends_on:
      - db" > docker-compose.yml

docker-compose build
docker-compose run web rails new . --force --database=postgresql
sudo chown -R $USER:$USER .

cd config
rm -R database.yml
touch database.yml

echo "default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: db
  username: postgres
  password:
development:
  <<: *default
  database: ${myapp}_development
test:
  <<: *default
  database: ${myapp}_test
production:
  <<: *default
  database: ${myapp}_production
  username: $myapp
  password: <%= ENV['${myapp^^}_DATABASE_PASSWORD'] %>
" > database.yml

docker-compose build

docker-compose run web rails db:create
