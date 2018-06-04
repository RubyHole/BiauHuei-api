# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    plugin :multi_route
      
    route('groups') do |r|
      @group_route = "#{@api_root}/groups"
      
      r.is do
        # GET api/v1/groups
        r.get do
          GetParticipatedGroups.call(auth_account: @auth_account, time: Time.new())
        rescue StandardError => error
          puts error.backtrace
          puts error.inspect
          #puts error.message
          r.halt 403, { message: 'Forbidden Request' }.to_json
        end
      end
      
      r.is 'new' do
        # POST api/v1/groups/new
        r.post do          
          new_data = JsonRequestBody.parse_symbolize(request.body.read)
                                    .merge(auth_account: @auth_account)
          new_group = CreateGroup.call(new_data)
          
          response.status = 201
          response['Location'] = "#{@group_route}/#{new_group.id}"
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
      
      r.is Integer do |group_id|
        # GET api/v1/groups/[group_id]
        r.get do
          GetGroupInfo.call(group_id: group_id, auth_account: @auth_account, time: Time.new())
        rescue StandardError => error
          puts error.backtrace
          puts error.inspect
          #puts error.message
          r.halt 404, { message: 'Group not found' }.to_json
        end
      end
      
    end
  end
end
