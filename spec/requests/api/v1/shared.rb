RSpec.shared_examples 'model with pagination' do
  before(:each) do
    subject
  end

  it 'should return default 10 entries' do
    # request
    get @path, nil, 'X-Auth-Token' => token_value

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure the right amount of messages are returned
    expect(json.length).to eq(10)
  end

  it 'should return max 25 entries' do
    # request
    get "#{@path}?per_page=100", nil, 'X-Auth-Token' => token_value
    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure the right amount of messages are returned
    expect(json.length).to eq(25)
  end

  it 'should paginate' do
    # request
    get "#{@path}?page=1&per_page=5", nil, 'X-Auth-Token' => token_value
    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure the right amount of messages are returned
    expect(json.length).to eq(5)
  end

  it 'should set headers' do
    # request
    get "#{@path}?page=2&per_page=10", nil, 'X-Auth-Token' => token_value
    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure the right amount of messages are returned
    expect(json.length).to eq(10)

    # check headers
    expect(response.header['Pagination-Page']).to be == 2
    expect(response.header['Pagination-Pages']).to be == 6
    expect(response.header['Pagination-Per-Page']).to be == 10
    expect(response.header['Pagination-Elements']).to be == 60
  end
end
