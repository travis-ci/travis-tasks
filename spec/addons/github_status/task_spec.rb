require 'spec_helper'

describe Travis::Addons::GithubStatus::Task do
  include Travis::Testing::Stubs

  let(:subject)    { Travis::Addons::GithubStatus::Task }
  let(:params)     { { tokens: { 'svenfuchs' => '12345', 'jdoe' => '67890' } } }
  let(:instance)   { subject.new(payload, params) }
  let(:url)        { '/repositories/549743/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'https://travis-ci.org/github/svenfuchs/minimal/builds/1?utm_source=github_status&utm_medium=notification' }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:io)         { StringIO.new }
  let(:gh_apps)    { stub('github_apps') }
  let(:installation_id) { '12345' }
  let(:rate_limit_data) { {"x-ratelimit-limit" => "60", "x-ratelimit-remaining" => "59", "x-ratelimit-reset" => (Time.now.to_i + 2000).to_s} }
  let(:redis)      { Redis.new(url: Travis.config.redis.url) }
  let(:redis_prefix) { subject.const_get("REDIS_PREFIX")}

  before do
    Travis.logger = Logger.new(io)
    params.fetch(:tokens, {}).keys.each do |u|
      redis.del(redis_prefix + "errored_users:" + u)
    end
  end

  def run
    instance.run
  end

  it 'posts status info for a created build' do
    payload["build"]["state"] = 'created'
    GH.expects(:post).with(url, state: 'pending', description: 'The Travis CI build is in progress', target_url: target_url, context: 'continuous-integration/travis-ci/push').returns({})
    run

    expect(io.string).to include('processed_with=')
  end

  it 'posts status info for a passed build' do
    payload["build"]["state"] = 'passed'
    GH.expects(:post).with(url, state: 'success', description: 'The Travis CI build passed', target_url: target_url, context: 'continuous-integration/travis-ci/push').returns({})
    run
  end

  it 'posts status info for a failed build' do
    payload["build"]["state"] = 'failed'
    GH.expects(:post).with(url, state: 'failure', description: 'The Travis CI build failed', target_url: target_url, context: 'continuous-integration/travis-ci/push').returns({})
    run
  end

  it 'posts status info for a errored build' do
    payload['build']["state"] = 'errored'
    GH.expects(:post).with(url, state: 'error', description: 'The Travis CI build could not complete due to an error', target_url: target_url, context: 'continuous-integration/travis-ci/push').returns({})
    run
  end

  it 'posts status info for a canceled build' do
    payload["build"]["state"] = 'canceled'
    GH.expects(:post).with(url, state: 'error', description: 'The Travis CI build could not complete due to an error', target_url: target_url, context: 'continuous-integration/travis-ci/push').returns({})
    run
  end

  it 'authenticates using the token passed into the task' do
    GH.expects(:with).with { |options| options[:token] == '12345' }.returns({})
    run
  end

  it 'authenticates using the next token if the first token failed' do
    GH.expects(:with).with { |options| options[:token] == '12345' }.raises(GH::Error.new(nil, nil, { response_status: 401, response_headers: rate_limit_data }))
    GH.expects(:with).with { |options| options[:token] == '67890' }.returns({})
    run
  end

  it 'accepts a single token using the legacy payload' do
    GH.expects(:with).with { |options| options[:token] == '12345' }.returns({})
    subject.new(payload, token: '12345').run
  end

  it 'does not raise if a 422 error was returned by GH' do
    error = { response_status: 422, response_headers: rate_limit_data }
    GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
    expect {
      run
    }.not_to raise_error
    expect(io.string).to include('response_status=422')
    expect(io.string).to include('reason=maximum_number_of_statuses')
  end

  it 'does not raise if a 403 error was returned by GH and marks the token invalid' do
    error = { response_status: 403, response_headers: rate_limit_data }
    GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
    expect {
      run
    }.not_to raise_error
    expect(io.string).to match /A request with token belonging to svenfuchs failed\./
    expect(io.string).to include('response_status=403')
    expect(io.string).to include('reason=incorrect_auth_or_suspended_acct')
    expect(redis.exists(redis_prefix + 'errored_users:' + 'svenfuchs')).to be true
  end

  it 'does not raise if a 404 error was returned by GH' do
    error = { response_status: 404, response_headers: rate_limit_data }
    GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
    expect {
      run
    }.not_to raise_error
    expect(io.string).to include('response_status=404')
    expect(io.string).to include('reason=repo_not_found_or_incorrect_auth')
    expect(io.string).to include('users_tried=')
  end

  context "a user token has been invalidated" do
    before :all do
      redis.set(redis_prefix + 'errored_users:' + 'svenfuchs', "")
    end

    after :all do
      redis.del(redis_prefix + 'errored_users:' + 'svenfuchs')
    end

    it "skips using the token" do
      expect { run }.not_to raise_error
      expect(io.string).to match /Token for svenfuchs failed/
    end
  end

  describe 'logging' do
    it 'warns about a failed request' do
      GH.stubs(:post).raises(GH::Error.new(nil, nil, {response_headers: rate_limit_data}))
      expect {
        run
      }.to raise_error RuntimeError
      expect(io.string).to include('error=not_updated')
      expect(io.string).to include('message=GH request failed')
      expect(io.string).to include('rate_limit=')
    end

    it "doesn't raise an error with bad credentials" do
      error = { response_status: 401, response_headers: rate_limit_data }
      GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
      expect {
        run
      }.to_not raise_error
    end
  end

  context 'with a github apps installation id' do
    let(:params) { { installation: installation_id } }
    let :response do
      stub(success?: true, status: 201)
    end

    it 'processes via github apps' do
      Travis::Backends::Github.any_instance.stubs(:github_apps).returns(gh_apps)
      gh_apps.expects(:post_with_app)
        .with(url, instance.send(:status_payload).to_json)
        .returns(response)
      run
    end
  end
end
