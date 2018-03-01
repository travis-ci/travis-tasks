require 'spec_helper'

describe Travis::Addons::Billing::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::Billing::Mailer::BillingMailer }
  let(:email) { stub('email', deliver: true) }
  let(:email_type) { 'charge_failed' }
  let(:handler) { described_class.new({}, email_type: email_type, subscription: subscription, charge: charge, event: event) }
  let(:subscription) { { first_name: 'Anja', last_name: 'Miller', valid_to: Time.now + 1.month } }
  let(:owner) { { name: 'Anja', login: 'anja' } }
  let(:billing_email) { 'anja@travis-test.com' }
  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  describe 'sends charge failed email' do
    mailer.expects(email_type).with(subscription, owner, charge, event).returns(email)
    handler.run
  end

end
