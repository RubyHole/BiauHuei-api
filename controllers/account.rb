# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    plugin :multi_route
      
    route('account') do |r|
      @account_route = "#{@api_root}/account"
      
      r.is 'authenticate' do
        # POST api/v1/account/authenticate
        r.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue UnauthorizedError => error
          puts [error.class, error.message].join ': '
          r.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
      
      r.is 'new' do
        # POST api/v1/account/new
        r.post do
          new_data = JsonRequestBody.parse_symbolize(request.body.read)
          new_account = Account.new(new_data)
          raise('Could not save account') unless new_account.save
          
          response.status = 201
          response['Location'] = "#{@account_route}/#{new_account.id}/groups"
          { message: 'Project saved', data: new_account }.to_json
        rescue Sequel::MassAssignmentRestriction
          r.halt 400, { message: 'Illegal Request' }.to_json
        rescue Sequel::UniqueConstraintViolation
          r.halt 409, { message: 'Account Exists' }.to_json
        rescue StandardError => error
          puts error.inspect
          r.halt 500, { message: error.message }.to_json
        end
      end
      
      r.is Integer, 'groups' do |account_id|
        # GET api/v1/account/[account_id]/groups
        r.get do
          GetParticipatedGroups.call(account_id: account_id, time: Time.new())
        rescue StandardError => error
          puts error.inspect
          r.halt 404, { message: error.message }.to_json
        end
      end
      
    end
  end
end
