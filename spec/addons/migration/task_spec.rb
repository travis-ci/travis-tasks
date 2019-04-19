require 'spec_helper'

describe Travis::Addons::Migration::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::Migration::Mailer::MigrationMailer }
  let(:email_type) { 'beta_confirmation' }
  let(:email) { stub('email', deliver: true) }
  let(:handler) { described_class.new({}, email_type: email_type, recipients: recipients, organizations: organizations, user_name: user_name) }
  let(:recipients) { %w(pavel@travis-ci.com) }
  let(:organizations) { %w(Assembla) }
  let(:user_name) { 'Pavel' }

  describe 'sends beta_confirmation email' do
    context 'with recipients' do
      it 'sends gdpr email' do
        mailer.expects(email_type).with(recipients, user_name, organizations).returns(email)
        handler.run
      end
    end
  end
end
