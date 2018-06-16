# frozen_string_literal: true

require 'http'

module BiauHuei
  # Error for invalid credentials
  class InvalidRegistration < StandardError; end

  # Find account and check password
  class EmailVerification
    SENDGRID_URL = 'https://api.sendgrid.com/v3/mail/send'

    def initialize(config)
      @config = config
    end

    def username_available?(registration)
      Account.first(username: registration[:username]).nil?
    end

    def email_body(registration)
      verification_url = registration[:verification_url]
      
      File.open("views/verification_email.html", "r") do |f|
        f.read.gsub! '---verification_url---', verification_url
      end
    end

    # rubocop:disable Metrics/MethodLength
    def send_email_verification(registration)
      HTTP.auth(
        "Bearer #{@config.SENDGRID_KEY}"
      ).post(
        SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' => registration[:email] }]
          }],
          from: { 'email' => 'noreply@biauhuei.com' },
          subject: 'BiauHuei Registration Verification',
          content: [
            { type: 'text/html',
              value: email_body(registration) }
          ]
        }
      )
    rescue StandardError => error
      puts error.inspect
      puts error.message
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
    # rubocop:enable Metrics/MethodLength

    def call(registration)
      raise(InvalidRegistration, 'Username already exists') unless
        username_available?(registration)

      send_email_verification(registration)
    end
  end
end
