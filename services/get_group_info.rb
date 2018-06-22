# frozen_string_literal: true

require 'ruby-duration'

module BiauHuei
  # Get group information based on group_id and auth_account
  class GetGroupInfo
    
    def self.call(group_id:, auth_account:, time:)
      instance = new(group_id: group_id, auth_account: auth_account, time: time)
      raise unless instance.legal_request?
      instance.to_json()
    end
    
    def initialize(group_id:, auth_account:, time:)
      @group_id = group_id
      @auth_account = auth_account
      @time = time
      
      @group = Group.first(id: @group_id)
      @account = Account.first(username: @auth_account['username'])
      @group_manager = GroupManager.new(@group, @time).auto_bid
    end
    
    attr_accessor :group_id, :account, :time, :group, :account, :group_manager
    
    def legal_request?
      policy = GroupPolicy.new(@group_manager, @account)
      policy.can_view?
    end
    
    def to_json
      JSON.pretty_generate(
        {
          group_id: @group.id,
          title: @group.title,
          description: @group.description,
          leader: @group_manager.leader,
          members: @group_manager.members,
          start_datetime: @group.created_at,
          round_interval: format_duration(@group.round_interval),
          round_base_fee: @group.round_fee.to_s,
          bidding_duration: format_duration(@group.bidding_duration),
          bidding_upset_price: @group.bidding_upset_price.to_s,
          current_round_id: current_round_id,
          rounds: rounds,
        }
      )
    end
    
    
    private
    
    
    def format_duration(seconds)
      duration = Duration.new(seconds)
      days = duration.weeks * 7 + duration.days
      hours = duration.hours
      minutes = duration.minutes
      seconds = duration.seconds
      "#{days} days, #{hours} hours, #{minutes} minutes, and #{seconds} seconds"
    end
    
    
    def current_round_id
      rid = @group_manager.current_round_id
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
        'start_date': @group.created_at,
        'end_date': @group.created_at,
        'bidding_end_date': @group.created_at,
        'is_finish': 'true',
        'total_saving': @group.round_fee * @group.members.length,
        'number_of_bids': 1.to_s,
        'winner': {
          'username': @group.leader.username,
          'bid_price': 0,  
        },
        'user': {
          round_fee: @group.round_fee.to_s,
          latest_bid: nil,
          bids_log: [],
          won_round_id: get_won_round_id(0),
          is_allowed_to_bid: false,
        },
      }
    end
    
    def rounds_info
      @group_manager.round_ids.map do |round_id|
        {
          'round_id': round_id.to_s,
          'start_date': @group_manager.start_date(round_id),
          'end_date': @group_manager.end_date(round_id),
          'bidding_end_date': @group_manager.bidding_end_date(round_id),
          'is_finish': @group_manager.is_round_finished(round_id).to_s,
          'total_saving': @group_manager.total_saving(round_id),
          'number_of_bids': @group_manager.bids_by_round(round_id).length,
          'winner': get_winner(round_id),
          'user': {
            round_fee: @group_manager.round_fee(round_id, account.id),
            latest_bid: get_latest_bid(round_id),
            bids_log: get_bids_log(round_id),
            won_round_id: get_won_round_id(round_id),
            is_allowed_to_bid: @group_manager.is_allowed_to_bid(round_id, account.id),
          },
        }
      end
    end
    
    def get_winner(round_id)
      highest_bid = @group_manager.highest_bid(round_id)
      return nil if highest_bid.nil?
      {
        'username': Account.first(id: highest_bid[:account_id]).username,
        'bid_price': highest_bid[:bid_price],
      }
    end
    
    def get_bid_info(bid)
      {
        'username': Account.first(id: bid[:account_id]).username,
        'bid_price': bid[:bid_price],
        'submit_type': bid[:submit_type],
        'created_at': bid[:created_at],
      }
    end
    
    def get_latest_bid(round_id)
      latest_bid = @group_manager.latest_bid(round_id, @account.id)
      latest_bid.nil? ? nil : get_bid_info(latest_bid)
    end
      
    def get_bids_log(round_id)
      bids = @group_manager.bids_by_round_id_account_id(round_id, @account.id)
      bids.map { |bid| get_bid_info(bid) }
    end
    
    def get_won_round_id(round_id)
      return 0 if @account == @group.leader
      won_bid = @group_manager.won_bid(@account.id)
      return -1 if won_bid.nil?
      won_bid[:round_id] < round_id ? won_bid[:round_id] : -1
    end
  end
end
