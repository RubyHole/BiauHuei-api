require 'http'

class GoogleAccount
  def initialize(access_token)
    @google_account = get_account(access_token)
  end
  
  def username
    @google_account['name'] + '@google'
  end
  
  def email
    @google_account['email']
  end
  
  def to_hash
    { 
      username: username,
      email: email,
    }
  end
  
  private_class_method
  
  def get_account(access_token)
    response = HTTP.headers(user_agent: 'Config Secure', accept:'application/json')
                          .auth("Bearer #{access_token}")
                          .get('https://www.googleapis.com/oauth2/v2/userinfo')
    raise unless response.status == 200
    response.parse
  end
end
