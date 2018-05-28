# frozen_string_literal: true

require 'ruby-duration'

module BiauHuei
  # Get group information based on group_id and account_id
  class GetGroupInfo
    
    def self.call(group_id:, account_id:, time:)
      instance = new(group_id: group_id, account_id: account_id, time: time)
      instance.to_json()
    end
    
    def initialize(group_id:, account_id:, time:)
      @group_id = group_id
      @account_id = account_id
      @time = time
      
      @group = Group.first(id: @group_id)
      @account = Account.first(id: @account_id)
      @bids_manager = BidsManager.new(@group, @time).auto_bid
    end
    
    attr_accessor :group_id, :account_id, :time, :group, :account, :bids_manager
    
    def to_json
      JSON.pretty_generate(
        {
          title: group.title,
          description: group.description,
          leader: bids_manager.leader,
          members: bids_manager.members,
          start_datetime: group.created_at,
          round_interval: Duration.new(group.round_interval).iso8601,
          round_base_fee: group.round_fee.to_s,
          bidding_duration: Duration.new(group.bidding_duration).iso8601,
          bidding_upset_price: group.bidding_upset_price.to_s,
          current_round_id: current_round_id,
          rounds: rounds,
        }
      )
    end
    
    def current_round_id
      rid = bids_manager.current_round_id
      rid.nil? ? 'Finished' : rid.to_s
    end
    
    def rounds
      rounds = []
      rounds.append(first_round_info)
      rounds += rounds_info
      rounds
    end
    
    def first_round_info
      {
        'round_id': 0.to_s,
        'start_date': group.created_at,
        'end_date': group.created_at,
        'bidding_end_date': group.created_at,
        'is_finish': 'true',
        'total_saving': group.round_fee * group.members.length,
        'number_of_bids': 1.to_s,
        'winner': {
          'username': group.leader.username,
          'bid_price': group.bidding_upset_price.to_s,  
        },
        'user': {
          round_fee: group.round_fee.to_s,
          latest_bid: nil,
          bids_log: [],
          is_allowed_to_bid: false,
        },
      }
    end
    
    def rounds_info
      bids_manager.round_ids.map do |round_id|
        {
          'round_id': round_id.to_s,
          'start_date': bids_manager.start_date(round_id),
          'end_date': bids_manager.end_date(round_id),
          'bidding_end_date': bids_manager.bidding_end_date(round_id),
          'is_finish': bids_manager.is_round_finished(round_id).to_s,
          'total_saving': bids_manager.total_saving(round_id),
          'number_of_bids': bids_manager.bids_by_round(round_id).length,
          'winner': get_winner(round_id),
          'user': {
            round_fee: bids_manager.round_fee(round_id, account_id),
            latest_bid: bids_manager.latest_bid(round_id, account_id),
            bids_log: bids_manager.bids_by_round_id_account_id(round_id, account_id),
            is_allowed_to_bid: bids_manager.is_allowed_to_bid(round_id, account_id),
          },
        }
      end
    end
    
    def get_winner(round_id)
      highest_bid = bids_manager.highest_bid(round_id)
      return nil if highest_bid.nil?
      {
        'username': Account.first(id: highest_bid[:account_id]).username,
        'bid_price': highest_bid[:bid_price],  
      }
    end
  end
end
