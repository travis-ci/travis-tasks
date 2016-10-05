require "spec_helper"

describe Travis::Addons::Discord::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Discord::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }

  before do
    subject.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    subject.new(payload, targets: targets).run
  end

  it "sends discord notifications about branches" do
    targets = ["12345:abc123-_"]
    message = {
      avatar_url: "https://travis-ci.org/images/travis-mascot-150.png",
      embeds: [{
        description: "Build [#2](https://travis-ci.org/svenfuchs/minimal/builds/1) ([62aae5f](https://github.com/svenfuchs/minimal/compare/master...develop)) of svenfuchs/minimal@master by Sven Fuchs passed in 1 min 0 sec",
        color: 38912
      }.stringify_keys]
    }.stringify_keys

    expect_discord("12345", "abc123-_", message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends discord notifications about pull requests" do
    targets = ["12345:abc123-_"]
    payload["build"]["pull_request"] = true
    payload["build"]["pull_request_number"] = "1"
    message = {
      avatar_url: "https://travis-ci.org/images/travis-mascot-150.png",
      embeds: [{
        description: "Build [#2](https://travis-ci.org/svenfuchs/minimal/builds/1) ([62aae5f](https://github.com/svenfuchs/minimal/compare/master...develop)) of svenfuchs/minimal@master in PR [#1](https://github.com/svenfuchs/minimal/pull/1) by Sven Fuchs passed in 1 min 0 sec",
        color: 38912
      }.stringify_keys]
    }.stringify_keys

    expect_discord("12345", "abc123-_", message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends discord notifications to multiple targets" do
    targets = ["12345:abc123-_", "67890:cba321_-"]
    message = {
      avatar_url: "https://travis-ci.org/images/travis-mascot-150.png",
      embeds: [{
        description: "Build [#2](https://travis-ci.org/svenfuchs/minimal/builds/1) ([62aae5f](https://github.com/svenfuchs/minimal/compare/master...develop)) of svenfuchs/minimal@master by Sven Fuchs passed in 1 min 0 sec",
        color: 38912
      }.stringify_keys]
    }.stringify_keys

    expect_discord("12345", "abc123-_", message)
    expect_discord("67890", "cba321_-", message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "allows specifying a custom branch template" do
    targets = ["12345:abc123-_"]
    payload["build"]["config"]["notifications"] = { discord: { branch_template: "Custom: %{author}"}} 
    message = {
      avatar_url: "https://travis-ci.org/images/travis-mascot-150.png",
      embeds: [{
        description: "Custom: Sven Fuchs",
        color: 38912
      }.stringify_keys]
    }.stringify_keys

    expect_discord("12345", "abc123-_", message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "allows specifying a custom pull request template" do
    targets = ["12345:abc123-_"]
    payload["build"]["pull_request"] = true
    payload["build"]["pull_request_number"] = "1"
    payload["build"]["config"]["notifications"] = { discord: { pull_request_template: "Custom: %{author}"}} 
    message = {
      avatar_url: "https://travis-ci.org/images/travis-mascot-150.png",
      embeds: [{
        description: "Custom: Sven Fuchs",
        color: 38912
      }.stringify_keys]
    }.stringify_keys

    expect_discord("12345", "abc123-_", message)

    run(targets)
    http.verify_stubbed_calls
  end

  it "ignores invalid configurations" do
    targets = ["123abc:==="]
    expect {
      run(targets)
    }.to_not raise_error
  end

  it "supports templates as a list" do
    targets = ["12345:abc123-_"]
    payload["build"]["config"]["notifications"] = { discord: { branch_template: ["Custom: %{author}", "More: %{branch}"]}} 
    message = {
      avatar_url: "https://travis-ci.org/images/travis-mascot-150.png",
      embeds: [{
        description: "Custom: Sven Fuchs\nMore: master",
        color: 38912
      }.stringify_keys]
    }.stringify_keys

    expect_discord("12345", "abc123-_", message)

    run(targets)
    http.verify_stubbed_calls
  end

  def expect_discord(id, token, body)
    path = "/api/webhooks/#{id}/#{token}"
    http.post(path) do |env|
      env[:url].request_uri.should == path
      MultiJson.decode(env[:body]).should == body
    end
  end

end
