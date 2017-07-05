#!/bin/bash
echo "##################################"
echo "          Task Automaton          "
echo "##################################"

echo -n "Enter the name of your app: "
read myapp
mkdir $myapp
cd $myapp
touch Dockerfile

echo "
FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /$myapp
WORKDIR /$myapp
ADD Gemfile /$myapp/Gemfile
ADD Gemfile.lock /$myapp/Gemfile.lock
RUN bundle install
ADD . $myapp
" > Dockerfile

touch Gemfile
echo
"
source 'https://rubygems.org'
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
