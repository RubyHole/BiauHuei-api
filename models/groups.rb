# frozen_string_literal: true

require 'json'
require  'sequel'

module BiauHuei
  # Models a group
  class Group < Sequel::Model
    one_to_many :members
    plugin :association_dependencies, members: :destroy
      
    plugin :timestamps
      
    plugin  :whitelist_security
    set_allowed_columns :name, :title, :description, :total_members, :round_period, :round_fee, :upset_price, :rounds_started_after, :bidding_ended_after
    
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
              total_members: total_members,
              round_period: round_period,
              round_fee: round_fee,
              upset_price: upset_price,
              rounds_started_after: rounds_started_after,
              bidding_ended_after: bidding_ended_after,
              rounds_start_date_time: rounds_start_date_time,
              current_round_id: current_round_id,
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
