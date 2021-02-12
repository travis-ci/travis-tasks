require 'spec_helper'

describe Travis::Addons::GithubStatus::Task do
  include Travis::Testing::Stubs

  let(:subject)    { Travis::Addons::GithubStatus::Task }
  let(:params)     { { tokens: { 'svenfuchs' => '12345', 'jdoe' => '67890' } } }
  let(:tokens)     { params.fetch(:tokens, {}).values }
  let(:instance)   { subject.new(payload, params) }
  let(:url)        { '/repositories/549743/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'https://travis-ci.org/github/svenfuchs/minimal/builds/1?utm_source=github_status&utm_medium=notification' }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:io)         { StringIO.new }
  let(:installation_id) { '12345' }
  let(:rate_limit_data) { {"x-ratelimit-limit" => "60", "x-ratelimit-remaining" => "59", "x-ratelimit-reset" => (Time.now.to_i + 2000).to_s} }
  let(:no_tokencheck_stack) { instance.send :gh_no_tokencheck_stack }

  def redis
    @redis ||= Redis.new(url: Travis.config.redis.url)
  end

  before do
    Travis.logger = Logger.new(io)
  end

  def run
    instance.run
  end

  it 'posts status info for a created build' do
    payload["build"]["state"] = 'created'
    Travis::Backends::Vcs.any_instance.expects(:create_status).with(
      id: payload['repository']['vcs_id'],
      type: payload['repository']['vcs_type'],
      ref: '62aae5f70ceee39123ef',
      pr_number: payload['pull_request'] && payload['pull_request']['number'],
      payload: {
        state: 'pending',
        description: 'The Travis CI build is in progress',
        target_url: target_url,
        context: 'continuous-integration/travis-ci/push'
      }
    )
    run

    expect(io.string).to include('processed_with=')
  end

  it 'posts status info for a passed build' do
    payload["build"]["state"] = 'passed'
    Travis::Backends::Vcs.any_instance.expects(:create_status).with(
      id: payload['repository']['vcs_id'],
      type: payload['repository']['vcs_type'],
      ref: '62aae5f70ceee39123ef',
      pr_number: payload['pull_request'] && payload['pull_request']['number'],
      payload: {
        state: 'success',
        description: 'The Travis CI build passed',
        target_url: target_url,
        context: 'continuous-integration/travis-ci/push'
      }
    )
    run
  end

  it 'posts status info for a failed build' do
    payload["build"]["state"] = 'failed'
    Travis::Backends::Vcs.any_instance.expects(:create_status).with(
      id: payload['repository']['vcs_id'],
      type: payload['repository']['vcs_type'],
      ref: '62aae5f70ceee39123ef',
      pr_number: payload['pull_request'] && payload['pull_request']['number'],
      payload: {
        state: 'failure',
        description: 'The Travis CI build failed',
        target_url: target_url,
        context: 'continuous-integration/travis-ci/push'
      }
    )
    run
  end

  it 'posts status info for a errored build' do
    payload['build']["state"] = 'errored'
    Travis::Backends::Vcs.any_instance.expects(:create_status).with(
      id: payload['repository']['vcs_id'],
      type: payload['repository']['vcs_type'],
      ref: '62aae5f70ceee39123ef',
      pr_number: payload['pull_request'] && payload['pull_request']['number'],
      payload: {
        state: 'error',
        description: 'The Travis CI build could not complete due to an error',
        target_url: target_url,
        context: 'continuous-integration/travis-ci/push'
      }
    )
    run
  end

  it 'posts status info for a canceled build' do
    payload["build"]["state"] = 'canceled'
    Travis::Backends::Vcs.any_instance.expects(:create_status).with(
      id: payload['repository']['vcs_id'],
      type: payload['repository']['vcs_type'],
      ref: '62aae5f70ceee39123ef',
      pr_number: payload['pull_request'] && payload['pull_request']['number'],
      payload: {
        state: 'error',
        description: 'The Travis CI build could not complete due to an error',
        target_url: target_url,
        context: 'continuous-integration/travis-ci/push'
      }
    )
    run
  end
end
