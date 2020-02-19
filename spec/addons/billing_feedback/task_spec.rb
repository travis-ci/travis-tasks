require 'spec_helper'

describe Travis::Addons::BillingFeedback::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::BillingFeedback::Mailer::BillingFeedbackMailer }
  let(:email) { stub('email', deliver: true) }
  let(:handler) { described_class.new({}, email_type: email_type, recipients: recipients, subscription: subscription, owner: owner, user: user, feedback: feedback) }
  let(:recipients) { ['anja@travis-ci.com'] }
  let(:subscription) { { first_name: 'Anja', last_name: 'Miller', valid_to: Time.now + 86400.to_i } }
  let(:owner) { { name: 'Anja_Org', login: 'anja_org', vcs_type: 'GithubUser', owner_type: 'User' } }
  let(:user) { { name: 'Anja_User', login: 'anja_user', email: 'anja@travis-ci.org' } }
  let(:feedback) { { test: "test" } }
  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  shared_examples 'sends billing email' do |email_type|
    let(:email_type) { email_type }

    specify 'sends to all recipients' do
      mailer.expects(email_type).with(recipients, subscription, owner, user, feedback).returns(email)
      handler.run
    end
  end

  shared_examples 'no email sent' do |email_type|
    let(:email_type) { email_type }

    specify do
      mailer.expects(email_type).never
      handler.run
    end
  end

  describe 'sends user feedback email' do
    context 'with recipients' do
      include_examples 'sends billing email', 'user_feedback'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'user_feedback'
    end
  end
end
