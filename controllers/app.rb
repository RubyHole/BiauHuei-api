# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    
    def symbolize_keys(hash)
      Hash[hash.map { |k, v| [k.to_sym, v] }]
    end
    
    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'BiauHueiAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = "api/v1"
          
          routing.is 'groups' do
            @group_route = "#{@api_root}/groups"
              
            # GET api/v1/groups
            routing.get do
              output = { data: Group.all }
              JSON.pretty_generate(output)
            end
          
            # POST api/v1/groups
            routing.post do
                
              new_data = JSON.parse(routing.body.read)
              new_group = Group.new(new_data)
              new_group.save
              response.status = 201
              response['Location'] = "#{@group_route}/#{new_group.id}"
              { message: 'Group saved', data: new_group }.to_json
                
            rescue Sequel::MassAssignmentRestriction
              routing.halt 400, { message: 'Illegal Request' }.to_json
                
            rescue StandardError => error
              routing.halt 500, { message: error.message }.to_json
                
            end
          end
          
          routing.on 'groups' do
            @group_route = "#{@api_root}/groups"
            
            # GET api/v1/groups/[group_id]
            routing.get String do |group_id|
              group = Group.first(id: group_id)
              group ? group.to_json : raise('Group not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end
          
          routing.is 'group' do
            @group_route = "#{@api_root}/group"
            
            # GET api/v1/group?group_id=[group_id]&account_id=[account_id]
            routing.get do
              routing.params['time'] = Time.new()
              GetGroupInfo.call(symbolize_keys(routing.params))
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end
          
          routing.is 'account', Integer, 'groups' do |account_id|
            # GET api/v1/account/[account_id]/groups
            routing.get do
              routing.params['account_id'] = account_id
              routing.params['time'] = Time.new()
              GetParticipatedGroups.call(symbolize_keys(routing.params))
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end
        end
      end
    end
  end
end
