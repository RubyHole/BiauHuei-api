# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, documents'
    create_accounts
    create_groups
    #create_owned_projects
    #create_documents
    #add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
GROUPS_INFO = YAML.load_file("#{DIR}/group_seeds.yml")
#PROJ_INFO=YAML.load_file("#{DIR}/projects_seed.yml")
#DOCUMENT_INFO=YAML.load_file("#{DIR}/documents_seed.yml")
#CONTRIB_INFO=YAML.load_file("#{DIR}/projects_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    BiauHuei::Account.create(account_info)
  end
end

def create_groups
  GROUPS_INFO.each do |group_info|
      
    new_group = BiauHuei::Group.create(
      title: group_info['title'],
      description: group_info['description'],
      round_interval: group_info['round_interval'],
      round_fee: group_info['round_fee'],
      bidding_duration: group_info['bidding_duration'],
      bidding_upset_price: group_info['bidding_upset_price']
    )
    
    leader = BiauHuei::Account.find(username: group_info['leader'])
    new_group.leader = leader
    
    group_info['members'].each do |username|
      member = BiauHuei::Account.find(username: username)
      new_group.add_member(member)
    end
    
    group_info['bids'].each do |bid_info|
      #previous_hash = Time.new().to_s
      new_bid = BiauHuei::Bid.create(
        bid_price: bid_info['bid_price'],
        submit_type: bid_info['submit_type'],
        #previous_hash: previous_hash,
      )
      new_bid.created_at += bid_info['time']
      new_bid.save
      
      new_group.add_bid(new_bid)
      
      account = BiauHuei::Account.find(username: bid_info['username'])
      account.add_bid(new_bid)
    end
    
    new_group.save
  end
end
