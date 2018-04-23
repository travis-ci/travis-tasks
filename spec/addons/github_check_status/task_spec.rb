require 'spec_helper'

describe Travis::Addons::GithubCheckStatus::Task do
  include Travis::Testing::Stubs

  before { ENV['GITHUB_PRIVATE_PEM'] = File.read('spec/fixtures/github_pem.txt') }
  after  { ENV.delete('GITHUB_PRIVATE_PEM') }

  let(:subject)    { Travis::Addons::GithubCheckStatus::Task.new(payload, installation: installation_id) }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:io)         { StringIO.new }
  let(:gh_apps)    { Travis::GithubApps.new installation_id }
  let(:installation_id) { '12345' }

  let(:conn) {
    Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post("/installations/12345/access_tokens") { |env| [201, {}, "{\"token\":\"github_apps_access_token\",\"expires_at\":\"2018-04-03T20:52:14Z\"}"] }
        stub.post("/repos/svenfuchs/minimal/check-runs") { |env| [201, {}, "{}"] }
      end
    end
  }

  before do
    Travis.logger = Logger.new(io)
  end

  it 'makes expected API calls' do
    subject.expects(:github_apps).returns(gh_apps)
    gh_apps.expects(:github_api_conn).with().times(2).returns(conn)
    subject.run
  end
end
