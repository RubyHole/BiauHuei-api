# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    
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
              puts "get"
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
            
            routing.on String do |group_id|
              routing.is 'members' do
                @member_route = "#{@group_route}/#{group_id}/members"
                
                # GET api/v1/groups/[group_id]/members
                routing.get do
                  output = { data: Group.first(id: group_id).members }
                  JSON.pretty_generate(output)
                end

                # POST api/v1/groups/[group_id]/members
                routing.post do
                    
                  new_data = JSON.parse(routing.body.read)
                  group = Group.first(id: group_id)
                  new_member = group.add_member(new_data)
                  response.status = 201
                  response['Location'] = "#{@member_route}/#{new_member.id}"
                  { message: 'Member added', data: new_member }.to_json
                
                rescue Sequel::MassAssignmentRestriction
                  routing.halt 400, { message: 'Illegal Request' }.to_json
                
                rescue NoMethodError
                  if group == nil
                    routing.halt 404, { message: 'The group is not existed' }.to_json
                  end
                      
                rescue StandardError => error
                  routing.halt 400, { message: 'Could not add member' }.to_json
                
                end
              end
              
              routing.on 'members' do
                @member_route = "#{@group_route}/#{group_id}/members"
                
                # GET api/v1/groups/[group_id]/members/[member_id]
                routing.get String do |member_id|
                  member = Member.where(group_id: group_id, id: member_id).first
                  member ? member.to_json : raise('Member not found')
                rescue StandardError => error
                  routing.halt 404, { message: error.message }.to_json
                end
              end
            end
          end
        end
      end
    end
  end
end
