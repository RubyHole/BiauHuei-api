# frozen_string_literal: true

require 'roda'

module BiauHuei
  # Web controller for BiauHuei API
  class Api < Roda
    route('auth') do |r|
      r.is 'register' do
        # POST api/v1/auth/register
        r.post do
          registration = SignedRequest.new(Api.config)
                                      .parse(request.body.read)
          EmailVerification.new(Api.config).call(registration)

          response.status = 201
          { message: 'Verification email sent' }.to_json
        rescue InvalidRegistration => error
          r.halt 400, { message: error.message }.to_json
        rescue StandardError => error
          puts "ERROR VERIFYING REGISTRATION: #{error.inspect}"
          puts error.message
          r.halt 500
        end
      end
      
      r.on 'authenticate' do
        r.is do
          # POST api/v1/auth/authenticate
          r.post do
            credentials = SignedRequest.new(Api.config)
                                       .parse(request.body.read)
            auth_account = AuthenticateEmailAccount.call(credentials)
            JSON.pretty_generate(auth_account)
          rescue StandardError => error
            puts "ERROR: #{error.class}: #{error.message}"
            r.halt '403', { message: 'Invalid credentials' }.to_json
          end
        end
        
        r.is 'google_sso' do
          # POST api/v1/auth/authenticate/google_sso
          r.post do
            auth_request = SignedRequest.new(Api.config)
                                        .parse(request.body.read)
            auth_account = AuthenticateSsoAccount.call(auth_request[:access_token], GoogleAccount)
            JSON.pretty_generate(auth_account)
          rescue StandardError => error
            puts "ERROR: #{error.class}: #{error.message}"
            r.halt '403', { message: 'Invalid credentials' }.to_json
          end
        end
        
        r.is 'github_sso' do
          # POST api/v1/auth/authenticate/github_sso
          r.post do
            auth_request = SignedRequest.new(Api.config)
                                        .parse(request.body.read)
            auth_account = AuthenticateSsoAccount.call(auth_request[:access_token], GithubAccount)
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
