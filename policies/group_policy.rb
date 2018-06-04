# frozen_string_literal: true

module BiauHuei
  # Policy to determine if an account can...
  class GroupPolicy
    def initialize(group_magager, account)
      @group_magager = group_magager
      @account = account
    end
    
    def can_view?
      account_is_leader? || account_is_member?
    end
    
    def can_bid?
      (account_is_leader? || account_is_member?) && account_is_allowed_to_bid?
    end
    
    def legal_bid_price?(bid_price)
      bid_price >= @group_magager.group.bidding_upset_price
    end
    
    
    private
    
    
    def account_is_leader?
      @group_magager.group.leader == @account
    end
    
    def account_is_member?
      @group_magager.group.members.include?(@account)
    end
    
    def account_is_allowed_to_bid?
      current_round_id = @group_magager.current_round_id
      @group_magager.is_allowed_to_bid(current_round_id, @account.id)
    end
  end
end
