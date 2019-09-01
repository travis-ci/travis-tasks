require 'spec_helper'

describe Travis::Addons::GithubStatus::Task do
  let(:params) { { tokens: { 'svenfuchs' => '12345', 'jdoe' => '67890' } } }
  # let(:url) { '/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=github_status&utm_medium=notification' }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:repo) { subject.send(:repository) }

  subject { described_class.new(payload, params) }

  it 'posts status info for a created build' do
    payload['build']['state'] = 'created'

    resp = stub(success?: true, body: '{}', status: 200)
    payload = { state: 'pending', description: 'The Travis CI build is in progress', target_url: target_url, context: 'continuous-integration/travis-ci/push' }.to_json
    Travis::RemoteVCS::Repository.any_instance.expects(:create_status).with(repo[:github_id], subject.send(:sha), payload).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  it 'posts status info for a passed build' do
    payload['build']['state'] = 'passed'

    resp = stub(success?: true, body: '{}', status: 200)
    payload = { state: 'success', description: 'The Travis CI build passed', target_url: target_url, context: 'continuous-integration/travis-ci/push' }.to_json
    Travis::RemoteVCS::Repository.any_instance.expects(:create_status).with(repo[:github_id], subject.send(:sha), payload).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  it 'posts status info for a failed build' do
    payload['build']['state'] = 'failed'

    resp = stub(success?: true, body: '{}', status: 200)
    payload = { state: 'failure', description: 'The Travis CI build failed', target_url: target_url, context: 'continuous-integration/travis-ci/push' }.to_json
    Travis::RemoteVCS::Repository.any_instance.expects(:create_status).with(repo[:github_id], subject.send(:sha), payload).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  it 'posts status info for a errored build' do
    payload['build']['state'] = 'errored'

    resp = stub(success?: true, body: '{}', status: 200)
    payload = { state: 'error', description: 'The Travis CI build could not complete due to an error', target_url: target_url, context: 'continuous-integration/travis-ci/push' }.to_json
    Travis::RemoteVCS::Repository.any_instance.expects(:create_status).with(repo[:github_id], subject.send(:sha), payload).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  it 'posts status info for a canceled build' do
    payload['build']['state'] = 'canceled'

    resp = stub(success?: true, body: '{}', status: 200)
    payload = { state: 'error', description: 'The Travis CI build could not complete due to an error', target_url: target_url, context: 'continuous-integration/travis-ci/push' }.to_json
    Travis::RemoteVCS::Repository.any_instance.expects(:create_status).with(repo[:github_id], subject.send(:sha), payload).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  describe 'logging' do
    it 'warns about a failed request' do
      resp = stub(success?: false, body: '{}', status: 403)
      Travis::RemoteVCS::Repository.any_instance.expects(:create_status).times(1).returns(resp)
      subject.expects(:info).times(1)
      subject.expects(:error).times(1)

      subject.run
    end

    it 'raises if error reason is unknown' do
      resp = stub(success?: false, body: '{}', status: 500)
      Travis::RemoteVCS::Repository.any_instance.expects(:create_status).times(1).returns(resp)
      subject.expects(:info).times(1)
      subject.expects(:error).times(1)

      expect { subject.run }.to raise_error RuntimeError
    end
  end
end
