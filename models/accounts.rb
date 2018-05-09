# frozen_string_literal: true

require 'json'
require 'sequel'

module BiauHuei
  # Models an account
  class Account < Sequel::Model
      
    one_to_many :leaded_groups, class: :'BiauHuei::Group', key: :leader_id
    #plugin :association_dependencies, leaded_groups: :destroy
    
    many_to_many :participated_groups, class: :'BiauHuei::Group',
                 join_table: :accounts_groups,
                 left_key: :member_id,  right_key: :group_id
    
    one_to_many :bids
      
    
    plugin :timestamps, update_on_create: true
    
    plugin  :whitelist_security
    set_allowed_columns :username, :email, :password
    
    
    def password=(new_password)
      self.salt = SecureDB.new_salt
      self.password_hash = SecureDB.hash_password(salt, new_password)
    end
    
    def password?(try_password)
      try_hashed = SecureDB.hash_password(salt, try_password)
      try_hashed == password_hash
    end
  end
end
