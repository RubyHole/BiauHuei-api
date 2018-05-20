# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    plugin :multi_route
      
    route('group') do |r|
      @group_route = "#{@api_root}/group"
      
      r.is 'new' do
        # POST api/v1/group/new
        r.post do
          new_data = JsonRequestBody.parse_symbolize(request.body.read)
          new_group = CreateGroup.call(new_data)
          
          response.status = 201
          response['Location'] = "#{@group_route}/#{new_group.id}/account/#{new_group.leader.id}"
          { message: 'Group saved', data: new_group }.to_json
        rescue ArgumentError
          r.halt 400, { message: 'Illegal Request' }.to_json
        rescue Sequel::MassAssignmentRestriction
          r.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => error
          puts error.inspect
          r.halt 500, { message: error.message }.to_json
        end
      end
      
      r.is Integer, 'account', Integer do |group_id, account_id|
        # GET api/v1/group/[group_id]/account/[account_id]
        r.get do
          GetGroupInfo.call(group_id: group_id, account_id: account_id, time: Time.new())
        rescue StandardError => error
          puts error.backtrace
          r.halt 404, { message: error.message }.to_json
        end
      end
      
    end
  end
end
