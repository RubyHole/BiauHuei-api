require_relative './spec_helper'

describe 'Test Member Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all members' do
    BiauHuei::Member.create(DATA[:members][0]).save
    BiauHuei::Member.create(DATA[:members][1]).save

    get 'api/v1/members'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single member' do
    existing_member = DATA[:members][1]
    BiauHuei::Member.create(existing_member).save
    id = BiauHuei::Member.first.id

    get "/api/v1/members/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
  end

  it 'SAD: should return error if unknown member requested' do
    get '/api/v1/members/foobar'
  
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new members' do
    existing_member = DATA[:members][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/members', existing_member.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0


    created = JSON.parse(last_response.body)['data']['attributes']
    member = BiauHuei::Member.first

    _(created['id']).must_equal member.id
    _(created['title']).must_equal existing_member['is_leader']
  end
end
