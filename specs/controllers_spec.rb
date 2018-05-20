# frozen_string_literal: true

require_relative './spec_helper'
require 'timecop'

describe 'Test Controllers/Routes' do
  include Rack::Test::Methods

  before do
    wipe_database
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
  end
  
  
  describe 'Test Get Routes' do
    
    before do
      # Seed Database
      puts
      print_env
      seed_database
    end
    
    it 'HAPPY: should be able to get list of all groups for an account' do
      # GET api/v1/account/[account_id]/groups
      
      # Leader
      account_id = BiauHuei::Group.first.leader.id
      get "api/v1/account/#{account_id}/groups"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['leaded_groups'].count).must_equal 2
      _(result['participated_groups'].count).must_equal 0
      
      # Member
      account_id = BiauHuei::Group.first.members.first.id
      get "api/v1/account/#{account_id}/groups"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['leaded_groups'].count).must_equal 0
      _(result['participated_groups'].count).must_equal 2
    end
    
    
    it 'HAPPY: should be able to get detail info about a group from view of an account' do
      # GET api/v1/group/[group_id]/account/[account_id]
            
      group_id = BiauHuei::Group.first.id
      account_id = BiauHuei::Group.first.members.first.id
      
      
      # At round 3 (where there are bids submited in previos round)
      t = BiauHuei::Group.first.created_at
      t += BiauHuei::Group.first.round_interval * 2
      Timecop.travel(t)
        
      account_id = BiauHuei::Group.first.leader.id
      get "api/v1/group/#{group_id}/account/#{account_id}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['rounds'].count).must_equal 4
      _(result['rounds'][-2]['winner']).wont_be_nil
      _(result['rounds'][-1]['winner']).must_be_nil
      
      
      # after round 5 (where there are no bid submited in round 4 and 5)
      t = BiauHuei::Group.first.created_at
      t += BiauHuei::Group.first.round_interval * 5
      Timecop.travel(t)
        
      account_id = BiauHuei::Group.first.leader.id
      get "api/v1/group/#{group_id}/account/#{account_id}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['rounds'].count).must_equal 6
      _(result['rounds'][-2]['winner']).wont_be_nil
      _(result['rounds'][-1]['winner']).wont_be_nil
    end
  end
 
 
  describe 'Account Authentication' do
    # POST api/v1/account/authenticate
    
    before do
      @account_data = DATA[:accounts][1]
      @account = BiauHuei::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { username: @account_data['username'],
                      password: @account_data['password'] }
      post 'api/v1/account/authenticate', credentials.to_json, @req_header

      _(last_response.status).must_equal 200
      auth_account = JSON.parse(last_response.body)
      _(last_response.status).must_equal 200
      _(auth_account['username'].must_equal(@account_data['username']))
      _(auth_account['email'].must_equal(@account_data['email']))
      _(auth_account['id'].must_be_nil)
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { username: @account_data['username'],
                      password: 'fakepassword' }

      assert_output(/invalid/i, '') do
        post 'api/v1/account/authenticate', credentials.to_json, @req_header
      end

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['username']).must_be_nil
      _(result['email']).must_be_nil
    end
  end
  
  
  describe 'Account Creation' do
    # POST api/v1/account/new
    
    before do
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/account/new', @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      account = BiauHuei::Account.first

      _(created['username']).must_equal @account_data['username']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/account/new', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
  
  
  describe 'Group Creation' do
    # POST api/v1/group/new
    
    before do
      @accounts_data = DATA[:accounts]
      @group_data = DATA[:groups][0].clone
      @group_data.delete('bids')
      
      @accounts_data.each do |account_info|
        BiauHuei::Account.create(account_info)
      end
    end

    it 'HAPPY: should be able to create new groups' do
      post 'api/v1/group/new', @group_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      group = BiauHuei::Group.first

      _(created['id']).must_equal group.id
      _(created['title']).must_equal @group_data['title']
      _(created['description']).must_equal @group_data['description']
    end

    it 'BAD: should not create group with illegal attributes' do
      bad_data = @group_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/group/new', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
  
  
  describe 'Bid Creation' do
    # POST api/v1/bid/new
    
    before do
      @accounts_data = DATA[:accounts]
      @group_data = DATA[:groups][0].clone
      @bid_data = @group_data['bids'][0].clone
      
      
      @accounts_data.each do |account_info|
        BiauHuei::Account.create(account_info)
      end
      
      
      @group_data.delete('bids')
      new_group = BiauHuei::Group.create(
        title: @group_data['title'],
        description: @group_data['description'],
        round_interval: @group_data['round_interval'],
        round_fee: @group_data['round_fee'],
        bidding_duration: @group_data['bidding_duration'],
        bidding_upset_price: @group_data['bidding_upset_price']
      )
      
      leader = BiauHuei::Account.find(username: @group_data['leader'])
      new_group.leader = leader
      
      @group_data['members'].each do |username|
        member = BiauHuei::Account.find(username: username)
        new_group.add_member(member)
      end
      
      new_group.save
      
      
      @bid_data['account_id'] = BiauHuei::Account.find(username: @bid_data['username']).id
      @bid_data['group_id'] = new_group.id
      @bid_data.delete('username')
      @bid_data.delete('time')
      @bid_data.delete('submit_type')
    end

    it 'HAPPY: should be able to create new bids' do
      post 'api/v1/bid/new', @bid_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      bid = BiauHuei::Bid.first

      _(created['id']).must_equal bid.id
      _(created['bid_price']).must_equal @bid_data['bid_price']
    end

    it 'BAD: should not create bid with illegal attributes' do
      bad_data = @bid_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/bid/new', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
