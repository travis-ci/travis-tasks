require 'spec_helper'

describe Travis::Addons::GithubCheckStatus::Task do
  include Travis::Testing::Stubs

  before { ENV['GITHUB_PRIVATE_PEM'] = File.read('spec/fixtures/github_pem.txt') }
  after  { ENV.delete('GITHUB_PRIVATE_PEM') }

  let(:subject)    { Travis::Addons::GithubCheckStatus::Task }
  let(:url)        { '/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'https://travis-ci.org/svenfuchs/minimal/builds/1?utm_source=github_status&utm_medium=notification' }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:io)         { StringIO.new }
  let(:gh_apps)    { Travis::GithubApps.new(accept_header: { "Accept" => "application/vnd.github.antiope-preview+json" }) }

  before do
    Travis.logger = Logger.new(io)
  end

   def run
    subject.new(payload, tokens: { 'svenfuchs' => '12345', 'jdoe' => '67890' }).run
  end

  it 'authenticates using the token passed into the task' do
    gh_apps.expects(:with).with { |options| options[:token] == '12345' }.returns({})
    run
  end


end
