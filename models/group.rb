# frozen_string_literal: true

require 'json'
require  'sequel'

module BiauHuei
  # Models a group
  class Group < Sequel::Model
    one_to_many :members
    plugin :association_dependencies, members: :destroy
    
    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'group',
            attributes: {
              id: id,
              title: title,
              description: description,
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
