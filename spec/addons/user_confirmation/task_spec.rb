# frozen_string_literal: true

require 'spec_helper'

describe Travis::Addons::UserConfirmation::Task do
  include Travis::Testing::Stubs

  let(:io) { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  shared_examples 'sends email' do |stage|
    let(:mailer) { Travis::Addons::UserConfirmation::Mailer::UserConfirmationMailer }
    let(:email) { stub('email', deliver: true) }
    let(:stage) { stage }
    let(:owner) { { name: 'Joe', login: 'joe', billing_slug: 'user', vcs_type: 'GithubUser', owner_type: 'User' } }
    let(:confirmation_url) { 'https://confirm.me/12345' }
    let(:token_valid_to) { '2021-02-08 14:14:14' }
    let(:recipients) { %w{joe@travis-ci.com joe@[bademail].home} }
    let(:params) do
      { owner: owner, confirmation_url: confirmation_url, token_valid_to: token_valid_to }
    end
    let(:handler) do
      described_class.new({},
                          stage: stage,
                          recipients: recipients,
                          owner: owner,
                          confirmation_url: confirmation_url,
                          token_valid_to: token_valid_to)
    end

    specify 'sends to filtered recipients' do
      mailer.expects(stage).with([recipients.first], params).returns(email)
      handler.run
    end
  end

  describe 'account_activated email' do
    it_behaves_like 'sends email', 'account_activated'
  end

  describe 'confirm_account email ' do
    it_behaves_like 'sends email', 'confirm_account'
  end
end
