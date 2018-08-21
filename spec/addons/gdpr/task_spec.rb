require 'spec_helper'

describe Travis::Addons::Gdpr::Task do
  include Travis::Testing::Stubs

  let(:mailer) { Travis::Addons::Gdpr::Mailer::GdprMailer }
  let(:email) { stub('email', deliver: true) }
  let(:handler) { described_class.new({}, email_type: email_type, recipients: recipients, request_date: Date.today, user_name: 'Anja', url: 'http://s3.travis-ci.dev/') }
  let(:recipients) { ['anja@travis-ci.com'] }
  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  shared_examples 'sends gdpr email' do |email_type, *params|
    let(:email_type) { email_type }

    specify 'sends to all recipients' do
      mailer.expects(email_type).with(recipients, *params).returns(email)
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

  describe 'sends export email' do
    context 'with recipients' do
      include_examples 'sends gdpr email', 'export', 'Anja', 'http://s3.travis-ci.dev/'
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'export'
    end
  end

  describe 'sends purge email' do
    let(:url) { nil }

    context 'with recipients' do
      include_examples 'sends gdpr email', 'purge', Date.today
    end

    context 'with no recipients' do
      let(:recipients) { [] }
      include_examples 'no email sent', 'purge'
    end
  end
end
