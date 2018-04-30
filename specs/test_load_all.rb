# frozen_string_literal: true

require 'rack/test'
include Rack::Test::Methods

require_relative'../init'

def app
  BiauHuei::Api
end
