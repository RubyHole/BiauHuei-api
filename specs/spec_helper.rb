ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:groups].delete
  app.DB[:members].delete
end

DATA = {}
DATA[:groups] = YAML.safe_load File.read('db/seeds/group_seeds.yml')
DATA[:members] = YAML.safe_load File.read('db/seeds/member_seeds.yml')