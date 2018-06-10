# frozen_string_literal: true

module BiauHuei
  # Find or create sso account
  class AuthenticateSsoAccount
    def self.call(access_token, oAuthAccount)
      sso_account = oAuthAccount.new(access_token).to_hash()
      account = find_or_create_sso_account(sso_account)
      { account: account, auth_token: AuthToken.create(account) }
    end
    
    private_class_method
    
    def self.find_or_create_sso_account(sso_account)
      SsoAccount.first(sso_account) || SsoAccount.create(sso_account)
    end
  end
end
    