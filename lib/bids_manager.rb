# frozen_string_literal: true

# BidsManager
class BidsManager
  
  ## Call setup once to pass in configvariable with DB_KEY attribute
  #def self.setup(config)
  #    @config = config
  #end
  #
  #def self.lastest_hash(group)
  #  lastest_hash = @config.DB_KEY
  #end
  
  attr_accessor :time, :round_id_map, :account_id_map
  
  def self.setup(account_model, group_model, bid_model)
    @@Account = account_model
    @@Group = group_model
    @@Bid = bid_model
  end
    
  def initialize(group, time)
    @group = group
    @time = time
    @round_id_map = __get_round_id_map__(group)
    @account_id_map = __get_account_id_map__(group)
  end
  
  def leader
    {
      username: @group.leader.username,
      email: @group.leader.email,
    }
  end
  
  def members
    @group.members.map do |member|
      {
        username: member.username,
        email: member.email,
      }
    end
  end
  
  def start_date(round_id)
    @group.created_at + @group.round_interval * (round_id - 1)
  end
  
  def end_date(round_id)
    @group.created_at + @group.round_interval * round_id 
  end
  
  def bidding_end_date(round_id)
    @group.created_at + @group.round_interval * (round_id - 1) + @group.bidding_duration
  end
  
  def bids
    bids = @group.bids.map do |bid|
      {
        bid_price: bid.bid_price,
        created_at: bid.created_at,
      }
    end
    bids.sort_by { |bid| bid[:created_at] }
  end
  
  def valid_round_id?(round_id)
    round_id <= @group.members.length ? true : false
  end
  
  def current_round_id
    round_id = ((@time - @group.created_at) / @group.round_interval).floor + 1
    valid_round_id?(round_id) ? round_id : nil
  end
  
  def round_ids
    if !current_round_id.nil?
      (1..current_round_id).to_a
    else
      (1..@group.members.length).to_a
    end
  end
  
  def overdue_round_ids
    if !current_round_id.nil?
      (1...current_round_id).to_a
    else
      (1..@group.members.length).to_a
    end
  end
  
  def bids_by_round(round_id)
    #if !@round_id_map.keys.include?(round_id)
    #  return []
    #end
    return [] if !round_is_bided?(round_id)
    @round_id_map[round_id].map do |idx|
      bids[idx]
    end
  end
  
  def bids_by_round_id_account_id(round_id, account_id)
    #if !@round_id_map.keys.include?(round_id)
    #  return []
    #end
    return [] if !is_bid(round_id, account_id)
    idxes = (@round_id_map[round_id].to_set & @account_id_map[account_id].to_set).to_a
    idxes.map do |idx|
      bids[idx]
    end
  end
  
  def latest_bid(round_id, account_id)
    return nil if !is_bid(round_id, account_id)
    idxes = (@round_id_map[round_id].to_set & @account_id_map[account_id].to_set).to_a
    idxes = idxes.sort_by { |i| i }
    bids[idxes.last]
  end
  
  def highest_bid(round_id)
    return nil if !is_round_finished(round_id)
    return nil if !round_is_bided?(round_id)
    bids = bids_by_round(round_id)
    bids.sort_by { |bid| bid[:bid_price] }.last
  end
  
  def is_round_finished(round_id)
    overdue_round_ids.include?(round_id)
  end
    
  def round_is_bided?(round_id)
    @round_id_map.include?(round_id) ? true : false
  end
  
  def is_bid(round_id, account_id)
    return false if @round_id_map.include?(round_id) != true
    return false if @account_id_map.keys.include?(account_id) != true
    (@round_id_map[round_id].to_set & @account_id_map[account_id].to_set).to_a.count > 0 ? true : false
  end
  
  def is_won(round_id, account_id)
    bid = highest_bid(round_id)
    return false if bid.nil?
    bid[:account_id] == account_id ? true : false
  end
    
  def won_bid(account_id)
    #rids = round_ids.select { |i| i < current_round_id }
    rids = overdue_round_ids
    rids.each do |round_id|
      if is_won(round_id, account_id)
        bid = highest_bid(round_id)
        bid[:round_id] = round_id
        return bid
      end
    end
    return nil
  end
  
  def is_in_bidding_interval
    (@time - @group.created_at) - @group.round_interval * (current_round_id - 1) < @group.bidding_duration
  end
  
  def is_won_a_bid(account_id)
    won_bid(account_id) ? true : false
  end
  
  def is_allowed_to_bid(round_id, account_id)
    return false if account_id == @group.leader.id
    return false if is_round_finished(round_id)
    is_in_bidding_interval && (!is_won_a_bid(account_id)) ? true : false
  end
  
  def total_saving(round_id)
    # round_id start from 1, should add leader's bid price
    base_saving = @group.round_fee * @group.members.length + @group.bidding_upset_price
    rids = round_ids.select { |i| i < round_id }
    rids.reduce(base_saving) do |sum, rid|
      sum + highest_bid(rid)[:bid_price]
    end
  end
    
  def round_fee(round_id, account_id)
    bid = won_bid(account_id)
    if bid && bid[:round_id] < round_id
      @group.round_fee + bid[:bid_price]
    else
      @group.round_fee
    end
  end
  
  def unbided_members
    all_account_ids = @group.members.map { |member| member.id }
    all_account_ids.select { |account_id| won_bid(account_id) == nil }
  end
  
  # Automatically check and assign bid to overdue and unbided round
  def auto_bid
    unbided_rids = overdue_round_ids.select { |round_id| bids_by_round(round_id).empty? }
    remained_members = unbided_members
    
    unbided_rids.each do |rid|
      random_choosed_member = remained_members[rand(remained_members.length)]
      remained_members.delete(random_choosed_member)
      
      bid_info = {
        group_id: @group.id,
        account_id: random_choosed_member,
        submit_type: 'System',
        bid_price: @group.bidding_upset_price,
        created_at: @group.created_at + @group.round_interval * rid - 0.000000001,
      }
      add_new_bid(bid_info)
      #puts bid_info
    end
    
    self.class.new(@@Group.find(id: @group.id), @time)
  end
  
  def add_new_bid(bid_info)
    new_bid = @@Bid.create(
      bid_price: bid_info[:bid_price],
      submit_type: bid_info[:submit_type],
      #previous_hash: previous_hash,
    )
    new_bid.created_at = bid_info[:created_at]
    new_bid.save
    
    group = @@Group.find(id: bid_info[:group_id])
    group.add_bid(new_bid)
    
    account = @@Account.find(id: bid_info[:account_id])
    account.add_bid(new_bid)
  end
  
  def __get_round_id_map__(group)
    round_id_map = {}
    #round_ids.each { |round_id| round_id_map[round_id] = [] }
    group.bids.each_with_index.each do |bid, idx|
      round_id = ((bid.created_at - group.created_at) / group.round_interval).floor + 1
      round_id_map[round_id] = [] if round_id_map[round_id] == nil
      round_id_map[round_id].append(idx)
    end
    round_id_map
  end
  
  def __get_account_id_map__(group)
    account_id_map = {}
    group.bids.each_with_index.each do |bid, idx|
      account_id = bid.account_id
      account_id_map[account_id] = [] if account_id_map[account_id] == nil
      account_id_map[account_id].append(idx)
    end
    account_id_map
  end
  
end
