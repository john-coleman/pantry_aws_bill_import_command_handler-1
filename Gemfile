source 'https://rubygems.org'

gem 'daemons'
gem 'aws-sdk'
gem 'pantry_daemon_common', git: 'git@github.com:wongatech/pantry_daemon_common.git', :tag => 'v0.1.7'
gem 'rest-client'
gem 'em-winrm', git: 'https://github.com/besol/em-winrm.git'
gem "rufus-scheduler", "~> 3.0.2"

group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :test, :development do
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec-fire'
  gem 'rspec'
  gem 'pry-debugger'
  gem 'rake'
end
