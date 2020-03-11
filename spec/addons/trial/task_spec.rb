require 'spec_helper'

describe Travis::Addons::Trial::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::Trial::Mailer::TrialMailer }
  let(:email) { stub('email', deliver: true) }
  let(:handler) { described_class.new({}, stage: stage, recipients: recipients, owner: owner, builds_remaining: builds_remaining) }
  let(:owner) { { name: 'Joe', login: 'joe', billing_slug: 'user', vcs_type: 'GithubUser', owner_type: 'User' } }
  let(:recipients) { %w{joe@travis-ci.com joe@[bademail].home} }
  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  shared_examples 'sends trial email' do |stage|
    let(:stage) { stage }

    specify 'sends to filtered recipients' do
      mailer.expects(stage).with([recipients.first], owner, builds_remaining).returns(email)
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

  describe 'sends trial started email' do
    let(:builds_remaining) { 100 }

    context 'with recipients' do
      include_examples 'sends trial email', 'trial_started'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'trial_started'
    end
  end

  describe 'sends trial halfway email' do
    let(:builds_remaining) { 50 }

    context 'with recipients' do
      include_examples 'sends trial email', 'trial_halfway'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'trial_halfway'
    end
  end

  describe 'sends trial ending email' do
    let(:builds_remaining) { 10 }

    context 'with recipients' do
      include_examples 'sends trial email', 'trial_about_to_end'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'trial_about_to_end'
    end
  end

  describe 'sends trial ended email' do
    let(:builds_remaining) { 0 }

    context 'with recipients' do
      let(:recipients) { %w{joe@travis-ci.com} }
      include_examples 'sends trial email', 'trial_ended'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'trial_ended'
    end
  end
end
