# frozen_string_literal: true

require 'json'
require 'sequel'

module BiauHuei
  # Models a group
  class Group < Sequel::Model
    
    many_to_one :leader, class: :'BiauHuei::Account'
    
    many_to_many :members, class: :'BiauHuei::Account',
                 join_table: :accounts_groups,
                 left_key: :group_id,  right_key: :member_id
      
    one_to_many :bids
    
    
    plugin :association_dependencies
    add_association_dependencies bids: :destroy, members: :nullify
      
    plugin :timestamps, update_on_create: true
      
    plugin  :whitelist_security
    set_allowed_columns :name, :title, :description, :round_interval, :round_fee, :bidding_duration, :bidding_upset_price
    
    
    def title
      SecureDB.decrypt(self.title_secure)
    end

    def title=(plaintext)
      self.title_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(self.description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end
        
    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'group',
            attributes: {
              id: id,
              title: title, # encrypt
              description: description, # encrypt
              round_interval: round_interval,
              round_fee: round_fee,
              bidding_duration: bidding_duration,
              bidding_upset_price: bidding_upset_price,
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
