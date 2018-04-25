require_relative './spec_helper'

describe 'Test Group Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all groups' do
    BiauHuei::Group.create(DATA[:groups][0]).save
    BiauHuei::Group.create(DATA[:groups][1]).save

    get 'api/v1/groups'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single group' do
    existing_group = DATA[:groups][1]
    BiauHuei::Group.create(existing_group).save
    id = BiauHuei::Group.first.id

    get "/api/v1/groups/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['title']).must_equal existing_group['title']
  end

  it 'SAD: should return error if unknown group requested' do
    get '/api/v1/groups/foobar'
  
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new groups' do
    existing_group = DATA[:groups][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/groups', existing_group.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0


    created = JSON.parse(last_response.body)['data']['attributes']
    group = BiauHuei::Group.first

    _(created['id']).must_equal group.id
    _(created['title']).must_equal existing_group['title']
    _(created['total_members']).must_equal existing_group['total_members']
  end
end
