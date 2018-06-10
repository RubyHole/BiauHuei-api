# frozen_string_literal: true

require 'json'
require 'sequel'

module BiauHuei
  # Models an account
  class Account < Sequel::Model
    plugin :single_table_inheritance, :type,
           model_map: { 'email' => 'BiauHuei::EmailAccount',
                        'sso'   => 'BiauHuei::SsoAccount' }
      
    one_to_many :leaded_groups, class: :'BiauHuei::Group', key: :leader_id
    #plugin :association_dependencies, leaded_groups: :destroy
    
    many_to_many :participated_groups, class: :'BiauHuei::Group',
                 join_table: :accounts_groups,
                 left_key: :member_id,  right_key: :group_id
    
    one_to_many :bids
      
    
    plugin :timestamps, update_on_create: true
    
    plugin  :whitelist_security
    set_allowed_columns :username, :email, :password
    
    def to_json(options = {})
      JSON.pretty_generate(
        {
          type: 'account',
          username: username,
          email: email
        }, options
      )
    end
    
  end
end
