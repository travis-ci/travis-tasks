require 'spec_helper'

describe Travis::Addons::Gdpr::Mailer::GdprMailer do
  let(:recipients) { ['sergio@travis-ci.com'] }

  describe '#export' do
    subject(:mail) { described_class.export(recipients, user_name, export_url) }

    let(:user_name) { 'Sergio' }
    let(:export_url) { 'http://s3.travis-ci.dev/' }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.from).to eq(['success@travis-ci.com'])
      expect(mail.subject).to eq('Your data report')
      expect(mail.body).to match("Hi #{user_name}!")
      expect(mail.body).to match(export_url)
    end
  end

  describe '#purge' do
    subject(:mail) { described_class.purge(recipients, request_date) }

    let(:request_date) { Date.today }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.from).to eq(['success@travis-ci.com'])
      expect(mail.subject).to eq('Your data was purged')
      expect(mail.body).to match("your request on #{request_date.strftime('%Y-%m-%d')}")
    end
  end
end
