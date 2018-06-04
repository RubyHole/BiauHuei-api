# frozen_string_literal: true

module BiauHuei
  # Create a new bid.
  class CreateBid
    
    def self.call(auth_account:, group_id:, bid_price:)
      
      group = BiauHuei::Group.find(id: group_id)
      account = BiauHuei::Account.find(username: auth_account['username'])
        
      raise if group.nil? || account.nil?
      
      group_manager = GroupManager.new(group, Time.new()).auto_bid
      
      policy = GroupPolicy.new(group_manager, account)
      raise unless policy.can_bid?
      raise unless policy.legal_bid_price?(bid_price)
      
      new_bid = BiauHuei::Bid.create(
        bid_price: bid_price,
        submit_type: 'User',
        #previous_hash: previous_hash,
      )
      new_bid.save
      
      raise('Could not save bid') unless new_bid.save
      
      group.add_bid(new_bid)
      account.add_bid(new_bid)
      
      new_bid
      
    end
    
  end
end
