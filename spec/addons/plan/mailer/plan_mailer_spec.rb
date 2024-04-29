# frozen_string_literal: true
require 'spec_helper'

describe Travis::Addons::Plan::Mailer::PlanMailer do
  let(:owner) do
    {
      login: 'pavel-d',
      name: 'Pavel D',
      owner_type: 'User'
    }
  end
  let(:recipients) { %w(pavel@travis-ci.com) }
  let(:params) do
    {}
  end

  describe '#welcome' do

    before :each do
      Travis.config.enterprise = false
    end
    subject(:mail) { described_class.welcome(recipients, owner, params) }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.body).to match('Please select a plan in order to use Travis CI.')
    end
  end

  describe '#welcome enterprise' do
    before :each do
      Travis.config.enterprise_platform.host = 'https://test-travis.com'
      Travis.config.enterprise = true
    end
    subject(:mail) { described_class.welcome(recipients, owner, params) }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.body).to match(Travis.config.enterprise_platform.host)
    end
  end
end
