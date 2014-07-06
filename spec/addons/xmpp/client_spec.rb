require 'spec_helper'

describe Travis::Addons::Xmpp::Client do
  Jabber.debug = true

  let(:subject)       { Travis::Addons::Xmpp::Client }
  let(:jid)           { 'travis_bot' }
  let(:room_jid)      { 'travis' }
  let(:message)       { 'hello' }
  let(:xmpp_client)   { stub(auth: true, connect: true, close: true, send: true) }
  let(:muc_client)    { stub(join: true, say: true, active?: false) }
  let(:password)      { 'secret' }
  let(:recipient_jid) { 'user_jid' }

  before do
    ::Jabber::Client.stubs(:new).returns xmpp_client
  end

  describe '#connect' do
    it 'authenticates with the password' do
      xmpp_client.expects(:auth).with(password)
      subject.new(jid, password).connect
    end
  end

  describe '#send_user' do
    it 'sends the message' do
      xmpp_client.expects(:send)
      subject.new(jid, password).send_user(recipient_jid, message)
    end
  end

  describe '#run' do
    it 'ensures the close of client' do
      xmpp_client.expects(:close)
      subject.new(jid, password).run { raise 'An unexpected error' } rescue nil
    end

    it 'connects before running the code' do
      xmpp_client.expects(:connect)
      subject.new(jid, password).run { 'Some code' }
    end
  end
end
