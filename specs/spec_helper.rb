# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def print_env
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

def wipe_database
  BiauHuei::Api.DB[:schema_seeds].delete if app.DB.tables.include?(:schema_seeds)
  BiauHuei::Group.dataset.destroy
  BiauHuei::Account.dataset.destroy
end

def seed_database
  require 'sequel'
  Sequel.extension :migration
  
  require 'sequel/extensions/seed'
  Sequel::Seed.setup(:test)
  Sequel.extension :seed
  Sequel::Seeder.apply(BiauHuei::Api.DB, 'db/seeds')
end

DATA = {}
DATA[:accounts] = YAML.safe_load File.read('db/seeds/account_seeds.yml')
DATA[:groups] = YAML.safe_load File.read('db/seeds/group_seeds.yml')
