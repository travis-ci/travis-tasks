require 'spec_helper'

describe Travis::Addons::Pushover::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Pushover::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }

  before do
    subject.any_instance.stubs(:http).returns(client)
  end

  def run(users, api_key)
    subject.new(payload, users: users, api_key: api_key).run
  end

  it "sends pushover notifications to the given targets" do
    message = '[travis-ci] svenfuchs/minimal#2 (master): the build has passed. Details: http://travis-ci.org/svenfuchs/minimal/builds/1'
    api_key = 'foobarbaz'
    users = ['userkeyone', 'userkeytwo']
    
    expect_pushover('foobarbaz', 'userkeyone', message)
    expect_pushover('foobarbaz', 'userkeytwo', message)
    
    run(users, api_key)
    http.verify_stubbed_calls
  end

  it 'using a custom template' do
    template = '%{repository} %{commit}'
    message = 'svenfuchs/minimal 62aae5f'
    payload['build']['config']['notifications'] = { pushover: { template: template} }
    api_key = 'foobarbaz'
    users = ['userkeythree', 'userkeyfour']
    
    expect_pushover('foobarbaz', 'userkeythree', message)
    expect_pushover('foobarbaz', 'userkeyfour', message)

    run(users, api_key)
    http.verify_stubbed_calls
  end

  def hash_to_query(hash)
    return URI.encode(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
  end
  
  def expect_pushover(token, user, message)
    host = "api.pushover.net"
    path = "/1/messages.json"
    expected_hash = {:message => message, :user => user, :token => token}
    
    http.post(path) do |env|
      expect(env[:url].host).to eq(host)
      expect(env[:url].scheme).to eq("https")
      expect(env[:url].path).to eq(path)
      expect(Rack::Utils.parse_nested_query(env[:body])).to eq(expected_hash.stringify_keys)
    end
  end
end

