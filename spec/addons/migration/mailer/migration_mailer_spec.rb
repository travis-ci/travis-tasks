require 'spec_helper'

describe Travis::Addons::Migration::Mailer::MigrationMailer do
  let(:user_name) { 'pavel-d' }
  let(:recipients) { %w(pavel@travis-ci.com) }
  let(:organizations) { %w(Assembla) }

  describe '#beta_confirmation' do
    subject(:mail) { described_class.beta_confirmation(recipients, user_name, organizations) }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.from).to eq(['success@travis-ci.com'])
      expect(mail.subject).to eq("Your account, @#{user_name}, is ready to start migrating!")
      expect(mail.body).to match('Welcome to the migration beta!')
    end
  end
end
