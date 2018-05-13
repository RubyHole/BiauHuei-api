# frozen_string_literal: true

module BiauHuei
  # Create a new group.
  class CreateGroup
    
    def self.call(title:, description:, round_interval:, round_fee:, bidding_duration:, bidding_upset_price:, leader:, members:)
      
      new_group = BiauHuei::Group.create(
        title: title,
        description: description,
        round_interval: round_interval,
        round_fee: round_fee,
        bidding_duration: bidding_duration,
        bidding_upset_price: bidding_upset_price,
      )
      
      leader = BiauHuei::Account.find(username: leader)
      new_group.leader = leader
      
      members.each do |username|
        member = BiauHuei::Account.find(username: username)
        new_group.add_member(member)
      end
      
      raise('Could not save group') unless new_group.save
      
      new_group
    
    end
  end
end
