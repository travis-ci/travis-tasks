require 'spec_helper'
require 'rack'

describe Travis::Addons::Webhook::Task do
  include Travis::Testing::Stubs

  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:repo_slug) { 'svenfuchs/minimal' }

  before do
    Travis.config.notifications = [:webhook]
    described_class.any_instance.stubs(:http).returns(client)
    described_class.any_instance.stubs(:repo_slug).returns(repo_slug)
  end

  def run(targets)
    described_class.new(payload, targets: targets, token: '123456').run
  end

  describe 'given a task payload' do
    let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
    let(:data)    { described_class.new(payload).payload }

    it 'data' do
      expect(data.except(:repository, :matrix)).to eql(
        id: 1,
        number: 2,
        status: 0,
        result: 0,
        status_message: 'Passed',
        result_message: 'Passed',
        started_at: '2014-04-03T10:21:05Z',
        finished_at: '2014-04-03T10:22:05Z',
        duration: 60,
        build_url: "https://travis-ci.org/svenfuchs/minimal/builds/1",
        config:  { rvm: ['1.8.7', '1.9.2'] },
        commit_id: 1,
        commit: '62aae5f70ceee39123ef',
        base_commit: 'base-commit',
        head_commit: 'head-commit',
        branch: 'master',
        compare_url: 'https://github.com/svenfuchs/minimal/compare/master...develop',
        message: 'the commit message',
        committed_at: '2014-04-03T09:22:05Z',
        committer_name: 'Sven Fuchs',
        committer_email: 'svenfuchs@artweb-design.de',
        author_name: 'Sven Fuchs',
        author_email: 'svenfuchs@artweb-design.de',
        type: 'push',
        state: 'passed',
        pull_request: false,
        pull_request_number: 1,
        pull_request_title: 'title',
        tag: 'v1.0.0'
      )
    end

    it 'repository' do
      expect(data[:repository]).to eql(
        id: 1,
        name: 'minimal',
        owner_name: 'svenfuchs',
        url: 'https://github.com/svenfuchs/minimal'
      )
    end

    it 'includes the build matrix' do
      expect(data[:matrix].first).to eql(
        id: 1,
        repository_id: 1,
        parent_id: 1,
        number: '2.1',
        state: 'passed',
        started_at: nil,
        finished_at: nil,
        config: { rvm: '1.8.7' },
        status: 0,
        result: 0,
        commit: '62aae5f70ceee39123ef',
        branch: 'master',
        message: 'the commit message',
        author_name: 'Sven Fuchs',
        author_email: 'svenfuchs@artweb-design.de',
        committer_name: 'Sven Fuchs',
        committer_email: 'svenfuchs@artweb-design.de',
        committed_at: '2014-04-03T09:22:05Z',
        compare_url: 'https://github.com/svenfuchs/minimal/compare/master...develop',
        allow_failure: false
      )
    end
  end

  it 'posts to the given targets, with the given payload and the given access token' do
    targets = ['http://one.webhook.com/path', 'http://second.webhook.com/path', 'http://user:password@three.webhook.com/path']

    targets.each do |url|
      uri = URI.parse(url)
      http.post uri.path do |env|
        expect(env[:url].host).to eq(uri.host)
        expect(env[:request_headers]['Authorization']).to eq(authorization_for(repo_slug, '123456'))
        expect(payload_from(env).keys.sort).to eq(payload.keys.map(&:to_s).sort)
        200
      end
    end

    run(targets)
    http.verify_stubbed_calls
  end

  it 'includes a Travis-Repo-Slug header' do
    url = 'https://one.webhook.com/path'
    uri = URI.parse(url)
    http.post uri.path do |env|
      expect(env[:url].host).to eq(uri.host)
      expect(env[:request_headers]['Travis-Repo-Slug']).to eq(repo_slug)
      expect(payload_from(env).keys.sort).to eq(payload.keys.map(&:to_s).sort)
      200
    end

    described_class.new(payload, targets: [url]).run
    http.verify_stubbed_calls
  end

  context "Signature header" do
    context "if not enabled in the config" do
      it "should not include a Signature header" do
        url = "https://one.webhook.com/path"
        uri = URI.parse(url)
        http.post uri.path do |env|
          expect(env[:url].host).to eq(uri.host)
          expect(env[:request_headers]["Signature"]).to be_nil
          expect(payload_from(env).keys.sort).to eq(payload.keys.map(&:to_s).sort)
          200
        end

        described_class.new(payload, targets: [url], token: "abc123").run
        http.verify_stubbed_calls
      end
    end

    context "if enabled in the config" do
      let(:private_key) { OpenSSL::PKey::RSA.new(2048) }

      before do
        Travis.config.webhook.signing_private_key = private_key.to_s
      end

      it "includes a Signature header" do
        url = "https://one.webhook.com/path"
        uri = URI.parse(url)
        http.post uri.path do |env|
          expect(env[:url].host).to eq(uri.host)
          expect(env[:request_headers]["Signature"]).not_to be_empty
          expect(payload_from(env).keys.sort).to eq(payload.keys.map(&:to_s).sort)
          200
        end

        described_class.new(payload, targets: [url], token: "abc123").run
        http.verify_stubbed_calls
      end

      it "the Signature header is verifiable" do
        url = "https://one.webhook.com/path"
        uri = URI.parse(url)
        http.post uri.path do |env|
          expect(env[:url].host).to eq(uri.host)
          expect(signature_verified?(env.body, env.request_headers["Signature"])).to eq(true)
          expect(payload_from(env).keys.sort).to eq(payload.keys.map(&:to_s).sort)
          200
        end

        described_class.new(payload, targets: [url], token: "abc123").run
        http.verify_stubbed_calls
      end
    end
  end

  def signature_verified?(body, signature)
    payload = CGI.unescape(body).sub!(/^payload=/, '')
    key = OpenSSL::PKey::RSA.new(private_key.public_key)
    key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(signature), payload)
  end

  def payload_from(env)
    JSON.parse(Rack::Utils.parse_query(env[:body])['payload'])
  end

  def authorization_for(slug, token)
    Digest::SHA2.hexdigest(slug + token)
  end
end
