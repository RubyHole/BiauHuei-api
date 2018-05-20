# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    plugin :multi_route
      
    route('bid') do |r|
      @bid_route = "#{@api_root}/bid"
      
      r.is 'new' do
        # Post api/v1/bid/new
        r.post do
          new_data = JsonRequestBody.parse_symbolize(request.body.read)
          new_bid = CreateBid.call(new_data)
          
          response.status = 201
          response['Location'] = "#{@api_root}/group/#{new_bid.group.id}/account/#{new_bid.account.id}"
          { message: 'Bid saved', data: new_bid }.to_json
        rescue ArgumentError
          r.halt 400, { message: 'Illegal Request' }.to_json
        rescue Sequel::MassAssignmentRestriction
          r.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => error
          puts error.inspect
          r.halt 500, { message: error.message }.to_json
        end
      end
      
    end
  end
end
