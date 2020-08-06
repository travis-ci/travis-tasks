require 'spec_helper'

describe Travis::Addons::Plan::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::Plan::Mailer::PlanMailer }
  let(:email) { stub('email', deliver: true) }
  let(:handler) { described_class.new({}, stage: stage, recipients: recipients, owner: owner, plan: plan) }
  let(:owner) { { name: 'Joe', login: 'joe', billing_slug: 'user', vcs_type: 'GithubUser', owner_type: 'User' } }
  let(:recipients) { %w{joe@travis-ci.com joe@[bademail].home} }
  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  shared_examples 'sends email' do |stage|
    let(:stage) { stage }

    specify 'sends to filtered recipients' do
      mailer.expects(stage).with([recipients.first], owner, plan).returns(email)
      handler.run
    end
  end

  shared_examples 'no email sent' do |stage|
    let(:stage) { stage }

    specify do
      mailer.expects(stage).never
      handler.run
    end
  end

  describe 'sends welcome email' do
    let(:plan) { 'Free Tier Plan' }

    context 'with recipients' do
      include_examples 'sends email', 'welcome'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'welcome'
    end
  end
end
