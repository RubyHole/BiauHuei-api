# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    
    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end
    
    route do |routing|
      response['Content-Type'] = 'application/json'
      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Requested' }.to_json)

      routing.root do
        { message: 'BiauHueiAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = "api/v1"
          
          routing.on 'account' do
            routing.route 'account'
          end
          
          routing.on 'group' do
            routing.route 'group'
          end
          
          routing.on 'bid' do
            routing.route 'bid'
          end
          
        end
      end
    end
  end
end
