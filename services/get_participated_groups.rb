# frozen_string_literal: true

require 'ruby-duration'

module BiauHuei
  # Get all groups that an account_id participated in.
  class GetParticipatedGroups
    
    def self.call(account_id:, time:)
      instance = new(account_id: account_id, time: time)
      instance.to_json()
    end
    
    def initialize(account_id:, time:)
      @account_id = account_id
      @time = time
    end
    
    attr_accessor :account_id, :time
      
    def to_json()
      account = Account.first(id: @account_id)
      raise NoMethodError.new('Account is not existed.') if account.nil?
      
      JSON.pretty_generate(
        {
          leaded_groups: account.leaded_groups.map { |group| get_group_info(group) },
          participated_groups: account.participated_groups.map { |group| get_group_info(group) },
        }
      )
    end
    
    def get_group_info(group)
      {
        id: group.id.to_s,
        title: group.title,
        leader: group.leader.username,
        created_at: group.created_at,
        round: get_round(group),
        status: is_active?(group) ? "active" : "due",
      }
    end
    
    def get_round(group)
      total_rounds = group.members.length
      round_id = ((@time - group.created_at) / group.round_interval).floor + 1
      round_id <= total_rounds ? "#{round_id}/#{total_rounds}" : "#{total_rounds}/#{total_rounds}"
    end
    
    def is_active?(group)
      total_rounds = group.members.length
      round_id = ((@time - group.created_at) / group.round_interval).floor + 1
      round_id <= total_rounds
    end
  end
end
