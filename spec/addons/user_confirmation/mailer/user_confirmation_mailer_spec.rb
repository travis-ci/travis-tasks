# frozen_string_literal: true

require 'spec_helper'

describe Travis::Addons::UserConfirmation::Mailer::UserConfirmationMailer do
  let(:recipients) { %w[pavel@travis-ci.com] }

  describe '#account_activated' do
    let(:params) { { owner: { name: 'My Name' } } }
    subject(:mail) { described_class.account_activated(recipients, **params) }

    it 'contains the right data' do
      expect(mail.to(recipients)).to eq(recipients)
      expect(mail.from).to eq(['no-reply@travis-ci.com'])
      expect(mail.subject).to eq('Travis CI: Your account has been activated!')
      expect(mail.body).to match("Hello #{params[:owner][:name]}!")
      expect(mail.body).to match('Your account has been successfully activated.')
    end
  end

  describe '#confirm_account' do
    before { ENV['CONFIRMATION_TOKEN_VALID_FOR'] = 60 }
    let(:params) do
      {
        owner: { name: 'My Name' },
        confirmation_url: 'https://confirm.me.plx',
        token_valid_to: (Time.now.utc + 60 * 60).strftime('%Y-%m-%d %H:%M:%S')
      }
    end
    subject(:mail) { described_class.confirm_account(recipients, **params) }
    it 'contains the right data' do
      expect(mail.to(recipients)).to eq(recipients)
      expect(mail.from).to eq(['no-reply@travis-ci.com'])
      expect(mail.subject).to eq('Travis CI: Confirm your account.')
      expect(mail.body).to match("Hello #{params[:owner][:name]}!")
      expect(mail.body).to match('Please take a moment to confirm your account.')
      expect(mail.body)
        .to match('<p><a id="account-activated-button" href="https://confirm.me.plx" target="_blank">Confirm your account</a></p>')
      expect(mail.body)
        .to match('<p>Note: you must confirm your account in order to run builds on Travis CI. The confirmation link will expire after 60 minutes</p>')
    end
  end
end
