# frozen_string_literal: true

require 'json'
require 'sequel'

module BiauHuei
  # Models a bid
  class Bid < Sequel::Model
    
    many_to_one :account
    many_to_one :group

    plugin :timestamps, update_on_create: true
    
    plugin  :whitelist_security
    set_allowed_columns :bid_price, :submit_type, :previous_hash
    
    
    def bid_price
      SecureDB.decrypt(self.bid_price_secure).to_i
    end

    def bid_price=(price)
      self.bid_price_secure = SecureDB.encrypt(price.to_s)
    end
    
    #def previous_hash=(hash)
    #  @previous_hash = hash
    #end
    #
    #def after_create
    #  input = @previous_hash + bid_price.to_s + created_at.to_s
    #  self.blockchain_hash = SecureDB.hash_sha256(input)
    #  super
    #end
    
    
    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'bid',
            attributes: {
              id: id,
              bid_price: bid_price,
              submit_type: submit_type,
            }
          },
          included: {
            group: group,
            account: account,
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
