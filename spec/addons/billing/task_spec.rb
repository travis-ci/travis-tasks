require 'spec_helper'

describe Travis::Addons::Billing::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::Billing::Mailer::BillingMailer }
  let(:email) { stub('email', deliver: true) }
  let(:handler) { described_class.new({}, email_type: email_type, recipients: recipients, subscription: subscription, owner: owner, charge: charge, event: event, invoice: invoice, cc_last_digits: cc_last_digits) }
  let(:recipients) { ['anja@travis-ci.com'] }
  let(:subscription) { { first_name: 'Anja', last_name: 'Miller', valid_to: Time.now + 86400.to_i } }
  let(:owner) { { name: 'Anja', login: 'ami', vcs_type: 'GithubUser', owner_type: 'User' } }
  let(:charge) { { "object": "charge", "status": "succeeded" } }
  let(:event) { { "object": "event", "type": "invoice.payment_succeeded" } }
  let(:invoice) { { "object": "invoice" } }
  let(:cc_last_digits) { 1234 }
  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  shared_examples 'sends billing email' do |email_type|
    let(:email_type) { email_type }

    specify 'sends to all recipients' do
      mailer.expects(email_type).with(recipients, subscription, owner, charge, event, invoice, cc_last_digits).returns(email)
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

  describe 'sends charge failed email' do
    context 'with recipients' do
      include_examples 'sends billing email', 'charge_failed'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'charge_failed'
    end
  end

  describe 'sends invoice_payment_succeeded email' do
    context 'with recipients' do
      include_examples 'sends billing email', 'invoice_payment_succeeded'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'invoice_payment_succeeded'
    end
  end

  describe 'sends subscription cancelled email' do
    context 'with recipients' do
      include_examples 'sends billing email', 'subscription_cancelled'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'subscription_cancelled'
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

  describe 'sends user changetofree feedback email' do
    context 'with recipients' do
      include_examples 'sends billing email', 'changetofree_feedback'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'changetofree_feedback'
    end
  end

  describe 'sends user changetofree notification email' do
    context 'with recipients' do
      include_examples 'sends billing email', 'changetofree'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'changetofree'
    end
  end
end
