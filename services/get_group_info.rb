# frozen_string_literal: true

require 'ruby-duration'

module BiauHuei
  # Get group information based on group_id and account_id
  class GetGroupInfo
    
    def self.call(group_id:, account_id:, time:)
      group = Group.first(id: group_id)
      account = Account.first(id: account_id)
      
      bids_manager = BidsManager.new(group, time)
      
      JSON.pretty_generate(
        {
          account_id: account_id,
          title: group.title,
          description: group.description,
          start_datetime: group.created_at,
          round_interval: Duration.new(group.round_interval).iso8601,
          round_base_fee: group.round_fee.to_s,
          bidding_duration: Duration.new(group.bidding_duration).iso8601,
          bidding_upset_price: group.bidding_upset_price.to_s,
          current_round_id: self.current_round_id(bids_manager),
          rounds: self.rounds(group, bids_manager, account_id),
        }
      )
    end
    
    def self.current_round_id(bids_manager)
      rid = bids_manager.current_round_id
      rid.nil? ? 'Finished' : rid.to_s
    end
    
    def self.rounds(group, bids_manager, account_id)
      rounds = []
      rounds.append(self.first_round_info(group))
      rounds += self.rounds_info(group, bids_manager, account_id)
      rounds
    end
    
    def self.first_round_info(group)
      {
        'round_id': 0.to_s,
        'is_finish': 'true',
        'number_of_bids': 1.to_s,
        'winner': {
          'username': group.leader.username,
          'bid_price': group.bidding_upset_price.to_s,  
        },
        'user': {
          round_fee: group.round_fee.to_s,
          latest_bid: nil,
          bids_log: [],
          is_allowed_to_bid: false.to_s,
        },
      }
    end
    
    def self.rounds_info(group, bids_manager, account_id)
      bids_manager.round_ids.map do |round_id|
        {
          'round_id': round_id.to_s,
          'is_finish': bids_manager.is_round_finished(round_id).to_s,
          'number_of_bids': bids_manager.bids_by_round(round_id).length,
          'winner': self.get_winner(bids_manager, round_id),
          'user': {
            round_fee: bids_manager.round_fee(round_id, account_id),
            latest_bid: bids_manager.latest_bid(round_id, account_id),
            bids_log: bids_manager.bids_by_round_id_account_id(round_id, account_id),
            is_allowed_to_bid: bids_manager.is_won_a_bid(account_id),
          },
        }
      end
    end
    
    def self.get_winner(bids_manager, round_id)
      highest_bid = bids_manager.highest_bid(round_id)
      return nil if highest_bid.nil?
      {
        'username': Account.first(id: highest_bid[:account_id]).username,
        'bid_price': highest_bid[:bid_price],  
      }
    end
  end
end
