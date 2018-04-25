# frozen_string_literal: true

require 'rack/test'
include Rack::Test::Methods

require_relative '../app'
require_relative '../models/init'

def app
  BiauHuei::Api
end
