# frozen_string_literal: true

module BiauHuei
  # Create a new bid.
  class CreateBid
    
    def self.call(group_id:, account_id:, bid_price:)
      
      group = BiauHuei::Group.find(id: group_id)
      account = BiauHuei::Account.find(id: account_id)
      
      raise('Could not save bid') if group.nil? || account.nil?
        
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
