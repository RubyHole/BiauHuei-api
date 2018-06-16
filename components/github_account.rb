require 'http'

class GithubAccount
  def initialize(access_token)
    @github_account = get_account(access_token)
  end
  
  def username
    @github_account['login'] + '@github'
  end
  
  def email
    @github_account['email']
  end
  
  def to_hash
    { 
      username: username,
      email: email,
    }
  end
  
  private_class_method
  
  def get_account(access_token)
    response = HTTP.headers(user_agent: 'Config Secure',
                          authorization: "token #{access_token}",
                          accept:'application/json')
                          .get('https://api.github.com/user')
    raise unless response.status == 200
    response.parse
  end
end
