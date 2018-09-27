require 'spec_helper'

describe Travis::Addons::Email::Task do
  include Travis::Testing::Stubs

  let(:subject)    { Travis::Addons::Email::Task }
  let(:mailer)     { Travis::Addons::Email::Mailer::Build }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:email)      { stub('email', deliver: true) }
  let(:handler)    { subject.new(payload, recipients: recipients, broadcasts: broadcasts) }
  let(:broadcasts) { [broadcast] }
  let(:io)         { StringIO.new }

  attr_reader :recipients

  before :each do
    Travis.logger = Logger.new(io)
    @recipients = ['svenfuchs@artweb-design.de']
    mailer.stubs(:finished_email).returns(email)
  end

  it 'creates an email for the build email recipients' do
    mailer.expects(:finished_email).with(payload.deep_symbolize_keys, recipients, broadcasts).returns(email)
    handler.run
  end

  it 'sends the email' do
    email.expects(:deliver)
    handler.run
  end

  it 'reraises an error when sending an email' do
    expect {
      email.stubs(:deliver).raises(StandardError, "something's broken")
      handler.run
    }.to raise_error(StandardError)
  end

  it "doesn't reraise an error with bad recipient syntax" do
    expect {
      email.stubs(:deliver).raises(Net::SMTPServerBusy, "401 4.1.3 Bad recipient address syntax")
      handler.run
    }.not_to raise_error
  end

  it "doesn't reraise an error when recipient was rejected" do
    expect {
      email.stubs(:deliver).raises(Net::SMTPServerBusy, "450 4.1.1 <test@localhost.localdomain>: Recipient address rejected: User unknown in local recipient table")
      handler.run
    }.not_to raise_error
  end

 it "reraises an smtp server busy error when it's not about the syntax" do
    expect {
      email.stubs(:deliver).raises(Net::SMTPServerBusy, "403 2.2.2 Out of fish")
      handler.run
    }.to raise_error(Net::SMTPServerBusy)
  end

  it 'includes valid email addresses' do
    @recipients = ['me@email.org']
    expect(handler.recipients).to contain_recipients('me@email.org')
  end

  it 'ignores email addresses (me@email)' do
    @recipients = ['me@email']
    expect(handler.recipients).not_to contain_recipients('me@email')
  end

  it 'ignores email address ending in .local' do
    @recipients = ['me@email.local']
    expect(handler.recipients).not_to contain_recipients('me@email.local')
  end
end
