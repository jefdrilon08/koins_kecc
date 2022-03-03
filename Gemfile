source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'rails', '~> 6.0'
#gem 'pg', '>= 0.18', '< 2.0'
gem 'pg'
gem 'puma'
gem 'sass-rails', '~> 5.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'dotenv-rails'
gem 'haml'
gem 'devise'
gem 'simple_form'
gem 'awesome_print'
gem 'whenever'
gem 'mini_magick'
gem 'aws-sdk-s3', require: false
gem 'aws-sdk-sns'
gem 'kaminari'
gem 'activerecord-import'
gem 'config'
gem 'sidekiq'
gem 'cocoon'
gem 'redis'
gem 'caxlsx_rails'
gem 'caxlsx'
gem 'hirb'
gem 'numbers_and_words'
gem 'zip-zip'
gem 'tty-table'
gem 'rollbar'
gem 'httparty'
#gem 'rack-timeout'
gem 'newrelic_rpm'
gem 'sendgrid-ruby'
gem 'rack-cors'
gem 'jwt'
gem 'net-smtp', require: false
gem 'net-pop', require: false
gem 'net-imap', require: false

# TODO: Remove eventually
gem 'jquery-rails'

gem 'uglifier'
gem 'sprockets'

# Webpacker
gem 'webpacker', '~> 6.0.0.rc.6'

# For ruby 2.7.1
# Note for Ubuntu: Make synmlink to ln -s /bin/mkdir /usr/bin/mkdir
gem 'nokogiri'

group :production do
  gem 'puma_worker_killer'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'factory_bot_rails'
  gem 'derailed_benchmarks'
  gem 'derailed'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard-rspec', require: false
  gem 'bullet'

  # Profiling
  gem 'rack-mini-profiler'
  gem 'memory_profiler' # For memory profiling
  gem 'flamegraph' # For call-stack profiling flamegraphs
  gem 'stackprof'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'rspec-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
