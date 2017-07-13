source "https://rubygems.org"
ruby '2.1.7'
gem 'rails', '4.2.5.1'
gem 'responders', '~> 2.1'
gem 'activerecord-session_store'

gem 'sqlite3', group: [:development, :test]
gem 'puma'
gem 'pg'

gem 'airbrake'

gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'

gem 'jquery-rails'
gem 'mustache-js-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'select2-rails'
gem 'epi_js'

gem 'mysql2'
gem 'simple_form'
gem 'draper'
gem 'ransack'
gem 'will_paginate'
gem 'bootstrap-will_paginate'

gem 'devise', '>= 3.5.2'
gem 'devise_ldap_authenticatable', '>= 0.8.5'
gem 'devise_cas_authenticatable', '>= 1.5.0'
gem 'cancancan'

gem 'whenever'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed-plugins-airbrake'
gem 'daemons'
gem 'table-for'

gem 'carrierwave'
gem 'fuzzy-string-match'
gem 'animate-rails'
gem 'mathquill_rails', '~> 0.9.3.3'
gem 'to_xls', '~> 1.5', '>= 1.5.3'
gem 'chronic_duration'
gem 'amoeba'
gem 'axlsx'
gem 'axlsx_rails'
gem 'selenium-webdriver'

# Win32 specific gems
platforms :mswin, :mingw, :x64_mingw do
  # coffee-script-source >= 1.9 is broken on Windows
  gem 'coffee-script-source', '~> 1.8.0'

  # tzinfo-data isn't provided natively on Windows
  gem 'tzinfo-data', '~> 1.2015.1'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'byebug'
end

group :development do
  gem 'web-console', '~> 2.2.1'
  gem 'spring'
  gem 'quiet_assets'

  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-passenger', require: false
  gem 'epi_deploy', github: 'epigenesys/epi_deploy'

  gem 'thin'
  gem 'eventmachine', '>= 1.0.9.1'
  gem 'letter_opener'
  gem 'annotate'
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'poltergeist'
  gem 'rspec-instafail', require: false
  platforms :mswin, :mingw, :x64_mingw do
    # patched release to fix issues with project path names on Win32
    gem 'cliver', github: 'yaauie/cliver', ref: '5617ce'
  end

  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov'

end
gem 'rails_12factor', group: :production