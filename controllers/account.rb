# frozen_string_literal: true

require 'roda'
require 'json'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    plugin :halt
    plugin :multi_route
      
    route('accounts') do |r|
      @account_route = "#{@api_root}/accounts"
      
      r.is 'authenticate' do
        # POST api/v1/accounts/authenticate
        r.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateEmailAccount.call(credentials)
          JSON.pretty_generate(auth_account)
        rescue StandardError => error
          puts "ERROR: #{error.class}: #{error.message}"
          r.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
      
      r.is 'new' do
        # POST api/v1/accounts/new
        r.post do
          new_data = JsonRequestBody.parse_symbolize(request.body.read)
          new_account = EmailAccount.new(new_data)
          raise('Could not save account') unless new_account.save
          
          response.status = 201
          response['Location'] = "api/v1/groups"
          { message: 'Project saved', data: new_account }.to_json
        rescue Sequel::MassAssignmentRestriction
          r.halt 400, { message: 'Illegal Request' }.to_json
        rescue Sequel::UniqueConstraintViolation
          r.halt 409, { message: 'Account Exists' }.to_json
        rescue StandardError => error
          puts error.inspect
          puts error.backtrace
          r.halt 500, { message: error.message }.to_json
        end
      end
      
      r.is 'existed', String do |username|
        # GET api/v1/accounts/existed/[username]
        r.get do
          raise StandardError if @auth_account['username'].nil?
          username = URI.decode(username)
          account = Account.first(username: username)
          JSON.pretty_generate({
            'is_existed': account.nil? ? false : true
          })
        rescue StandardError => error
          r.halt 403, { message: 'Forbidden Request' }.to_json
        end
      end
      
      r.on 'authenticate' do
        r.is 'google_sso' do
          # POST api/v1/accounts/authenticate/google_sso
          r.post do
            access_token = JsonRequestBody.parse_symbolize(request.body.read)[:access_token]
            auth_account = AuthenticateSsoAccount.call(access_token, GoogleAccount)
            JSON.pretty_generate(auth_account)
          rescue StandardError => error
            puts "ERROR: #{error.class}: #{error.message}"
            r.halt '403', { message: 'Invalid credentials' }.to_json
          end
        end
        
        r.is 'github_sso' do
          # POST api/v1/accounts/authenticate/github_sso
          r.post do
            access_token = JsonRequestBody.parse_symbolize(request.body.read)[:access_token]
            auth_account = AuthenticateSsoAccount.call(access_token, GithubAccount)
            JSON.pretty_generate(auth_account)
          rescue StandardError => error
            puts "ERROR: #{error.class}: #{error.message}"
            r.halt '403', { message: 'Invalid credentials' }.to_json
          end
        end
      end
    end
  end
end
