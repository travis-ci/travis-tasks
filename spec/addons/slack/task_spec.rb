require 'spec_helper'

describe Travis::Addons::Slack::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Slack::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }

  before do
    subject.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    subject.new(payload, targets: targets).run
  end

  it "sends slack notifications to the given targets" do
    targets = ['team-1:token-1#channel1', 'team-2:token-2#channel1']
    message = {
      icon_url: "https://travis-ci.org/images/travis-mascot-150.png",
      channel: '#channel1',
      attachments: [{
        fallback: 'Build <https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=slack&utm_medium=notification|#2> (<https://github.com/svenfuchs/minimal/compare/master...develop|62aae5f>) of svenfuchs/minimal@master by Sven Fuchs passed in 1 min 0 sec',
        text: 'Build <https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=slack&utm_medium=notification|#2> (<https://github.com/svenfuchs/minimal/compare/master...develop|62aae5f>) of svenfuchs/minimal@master by Sven Fuchs passed in 1 min 0 sec',
        color: 'good'
      }.stringify_keys]
    }.stringify_keys

    expect_slack('team-1', 'token-1', message)
    expect_slack('team-2', 'token-2', message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "doesn't include a channel in the body when none is specified" do
    targets = ['team-1:token-1']
    message = {
      icon_url: "https://travis-ci.org/images/travis-mascot-150.png",
      attachments: [{
        fallback: 'Build <https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=slack&utm_medium=notification|#2> (<https://github.com/svenfuchs/minimal/compare/master...develop|62aae5f>) of svenfuchs/minimal@master by Sven Fuchs passed in 1 min 0 sec',
        text: 'Build <https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=slack&utm_medium=notification|#2> (<https://github.com/svenfuchs/minimal/compare/master...develop|62aae5f>) of svenfuchs/minimal@master by Sven Fuchs passed in 1 min 0 sec',
        color: 'good'
      }.stringify_keys]
    }.stringify_keys

    expect_slack('team-1', 'token-1', message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "allows specifying a custom template" do
    targets = ['team-1:token-1']
    payload['build']['config']['notifications'] = { slack: { template: 'Custom: %{author}'}}
    message = {
      icon_url: "https://travis-ci.org/images/travis-mascot-150.png",
      attachments: [{
        fallback: "Custom: Sven Fuchs",
        text: "Custom: Sven Fuchs",
        color: 'good'
      }.stringify_keys]
    }.stringify_keys
    expect_slack('team-1', 'token-1', message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "ignores garbage configurations" do
    targets = ['3109euaofjelw;arj;gfer//asfg=adfaf4lk3rj']
    expect {
      run(targets)
    }.to_not raise_error
  end

  it "supports a list as templates" do
    targets = ['team-1:token-1']
    payload['build']['config']['notifications'] = { slack: { template: ['Custom: %{author}', 'More: %{branch}']}}
    message = {
      icon_url: "https://travis-ci.org/images/travis-mascot-150.png",
      attachments: [{
        fallback: "Custom: Sven Fuchs\nMore: master",
        text: "Custom: Sven Fuchs\nMore: master",
        color: 'good'
      }.stringify_keys]
    }.stringify_keys
    expect_slack('team-1', 'token-1', message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends information about pull requests" do
    targets = ['team-1:token-1#channel1']
    payload['build']['pull_request'] = true
    payload['build']['pull_request_number'] = '1'

    expected_text = 'Build <https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=slack&utm_medium=notification|#2> (<https://github.com/svenfuchs/minimal/compare/master...develop|62aae5f>) of svenfuchs/minimal@master in PR <https://github.com/svenfuchs/minimal/pull/1|#1> by Sven Fuchs passed in 1 min 0 sec'

    message = {
      icon_url: "https://travis-ci.org/images/travis-mascot-150.png",
      channel: '#channel1',
      attachments: [{
        fallback: expected_text,
        text: expected_text,
        color: 'good'
      }.stringify_keys]
    }.stringify_keys

    expect_slack('team-1', 'token-1', message)

    run(targets)
    http.verify_stubbed_calls
  end


  def expect_slack(account, token, body)
    host = "#{account}.slack.com"
    path = "/services/hooks/travis?token=#{token}"

    http.post(path) do |env|
      expect(env[:url].host).to eq(host)
      expect(env[:url].request_uri).to eq(path)
      expect(MultiJson.decode(env[:body])).to eq(body)
    end
  end

end
