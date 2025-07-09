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

  describe '#end_trial' do

    subject(:mail) { described_class.end_trial_reminder(recipients, owner, params) }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.body).to match('We hope you\'ve been enjoying your free trial with us!')
      expect(mail.body).to_not match('SIGN UP')
    end
  end

  describe '#welcome' do

    before :each do
      Travis.config.enterprise = false
    end
    subject(:mail) { described_class.welcome(recipients, owner, params) }

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.body).to match('Please select a plan in order to use Travis CI.')
      expect(mail.body).to match('SIGN UP')
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

  describe '#plan_share_no_admin' do

    subject(:mail) { described_class.shared_plan_no_admin(recipients, owner, params) }

    let(:receiver) do
      {
        login: 'tester',
        name: 'Testing Tester',
        owner_type: 'Organization'
      }
    end

    let(:params) do
      { receiver: receiver,
       donor: owner,
       recipients: ['admin1@owner.org', 'admin2@owner.org']
      }
    end

    it 'contains the right data' do
      expect(mail.to).to eq(params[:recipients])
      expect(mail.body).to match('tester Travis CI account associated with your shared plan')
    end
  end

  describe '#csv_export_ready' do
    subject(:mail) do
      described_class.csv_export_ready(
        [recipient],
        owner,
        params
      )
    end

    let(:recipient) { 'nikola.granit@yahoo.com' }
    let(:owner) { { name: 'Ruby Monsters', login: 'rubymonsters', vcs_type: 'GithubUser', owner_type: 'User' } }
    let(:download_url) { 'https://example.com/report.csv' }
    let(:params) do
      {
        report: {
          download_url: download_url,
          expires_at: (Time.now + 86400).iso8601
        }
      }
    end

    it 'is addressed to the user' do
      expect(mail.to).to eq([recipient])
    end

    it 'comes from Travis' do
      expect(mail.from.first).to include('@travis-ci.com')
    end

    it 'has the right subject' do
      expect(mail.subject).to eq('Travis CI: Your Credits Consumption Report is Ready')
    end

    it 'contains the download link' do
      html = Capybara.string(mail.body.to_s)
      expect(html).to have_link('DOWNLOAD REPORT', href: download_url)
    end
  end
end
