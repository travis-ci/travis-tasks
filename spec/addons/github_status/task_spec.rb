require 'spec_helper'

describe Travis::Addons::GithubStatus::Task do
  include Travis::Testing::Stubs

  let(:subject)    { Travis::Addons::GithubStatus::Task }
  let(:url)        { '/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'https://travis-ci.org/svenfuchs/minimal/builds/1' }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:io)         { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  def run
    subject.new(payload, tokens: { 'svenfuchs' => '12345', 'jdoe' => '67890' }).run
  end

  it 'posts status info for a created build' do
    payload["build"]["state"] = 'created'
    GH.expects(:post).with(url, state: 'pending', description: 'The Travis CI build is in progress', target_url: target_url, context: 'continuous-integration/travis-ci/push').returns({})
    run
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
    GH.expects(:with).with { |options| options[:token] == '12345' }.raises(GH::Error.new(nil, nil, response_status: 401))
    GH.expects(:with).with { |options| options[:token] == '67890' }.returns({})
    run
  end

  it 'accepts a single token using the legacy payload' do
    GH.expects(:with).with { |options| options[:token] == '12345' }.returns({})
    subject.new(payload, token: '12345').run
  end

  it 'does not raise if a 422 error was returned by GH' do
    error = { response_status: 422 }
    GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
    expect {
      run
    }.not_to raise_error
    io.string.should include('response_status=422')
    io.string.should include('reason=maximum_number_of_statuses')
  end

  it 'does not raise if a 404 error was returned by GH' do
    error = { response_status: 404 }
    GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
    expect {
      run
    }.not_to raise_error
    io.string.should include('response_status=404')
    io.string.should include('reason=repo_not_found_or_incorrect_auth')
  end

  describe 'logging' do
    it 'warns about a failed request' do
      GH.stubs(:post).raises(GH::Error.new(nil))
      expect {
        run
      }.to raise_error
      io.string.should include('error=not_updated')
      io.string.should include('message=GH request failed')
    end

    it "doesn't raise an error with bad credentials" do
      error = { response_status: 401 }
      GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
      expect {
        run
      }.to_not raise_error
    end
  end
end
