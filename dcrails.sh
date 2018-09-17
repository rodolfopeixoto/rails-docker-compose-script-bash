#!/bin/bash
echo "##################################"
echo "          Task Automaton          "
echo "##################################"

echo "All the following gems will be installed"
echo "##################################"
echo "gem 'rails_best_practices'
gem 'rubocop', require: false
gem 'rubycritic', require: false
gem 'rails-i18n', '~> 5.0.0'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
end

 group :development do
   gem 'pry-rails'
   gem 'better_errors'
   gem 'binding_of_caller'
 end

group :test do
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'email_spec'
end"
echo "##################################"

echo -n "Enter the name of your app: "
read myapp

mkdir $myapp
cd $myapp
touch Dockerfile

echo "FROM ruby:2.5
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
gem 'rails', '5.2'
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

cd ../
rm -R Gemfile
touch Gemfile

echo "source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'rails_best_practices'

gem 'rubocop', require: false

gem 'rubycritic', require: false

gem 'rails-i18n', '~> 5.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # rspec-rails is a testing framework for Rails 3.x, 4.x and 5.0.
  gem 'rspec-rails'
  # factory_girl is a fixtures replacement with a straightforward definition syntax, support for multiple build strategies (saved instances, unsaved instances, attribute hashes, and stubbed objects), and support for multiple factories for the same class (user, admin_user, and so on), including factory inheritance.
  gem 'factory_girl_rails'
  # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'faker'
  # Acceptance test framework for web applications
  gem 'capybara'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Avoid repeating yourself, use pry-rails instead of copying the initializer to every rails project. This is a small gem which causes rails console to open pry. It therefore depends on pry.
  gem 'pry-rails'
  # Better error page for Rack apps
  gem 'better_errors'
  # Better error page for Rack apps
  gem 'binding_of_caller'
end

group :test do
  # Strategies for cleaning databases in Ruby. Can be used to ensure a clean state for testing. http://databasecleaner.github.io
  gem 'database_cleaner'
  # Collection of testing matchers extracted from Shoulda http://matchers.shoulda.io
  gem 'shoulda-matchers'
  # Collection of RSpec/MiniTest matchers and Cucumber steps for testing email in a ruby app using ActionMailer or Pony
  gem 'email_spec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
" > Gemfile
docker-compose build

docker-compose run web rails db:create

docker-compose run web rails g rspec:install
sudo chown -R $USER:$USER .
rm -R .rspec
touch .rspec
echo "--require spec_helper
--color
--require spec_helper
--format documentation
" > .rspec

echo "Environment set up! Now, you can go to the terminal and start the server"
echo " "
echo "Command: 'docker-compose up -d' in background or 'docker-compose up' showing all logs"
