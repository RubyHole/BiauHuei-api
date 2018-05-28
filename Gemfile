source 'https://rubygems.org'
ruby '2.5.1'

# Web API
gem 'roda'
gem 'puma'
gem 'json'

# Configuration
gem 'econfig'
gem 'rake'

# Diagnostic
gem 'pry'
gem 'rack-test'

# Security
gem 'rbnacl-libsodium'

# Services
gem 'http'

# Database
gem 'sequel'
gem 'hirb'
group :development, :test do
  gem 'sqlite3'
  gem 'sequel-seed'
end

group :production do
  gem 'pg'
end

# DateTime
gem 'ruby-duration'

# Development
group :development do
  gem'rubocop'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'timecop'
end

group :development, :test do
  gem 'rerun'
end
