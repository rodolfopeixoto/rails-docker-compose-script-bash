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
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
  " > Dockerfile
