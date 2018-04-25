# frozen_string_literal: true

require 'json'
require  'sequel'

module BiauHuei
  # Models a secret member
  class Member < Sequel::Model
    many_to_one :group
    #one_to_one :user
    
    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'member',
            attributes: {
              id: id,
              is_leader: is_leader,
            }
          },
          included: {
            group: group,
            #user: user,
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
