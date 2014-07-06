require 'spec_helper'

describe Travis::Addons::Xmpp::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Xmpp::Task }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:client)  { stub(run: true, send_channel: true, send: true) }
  let(:rooms)   do
    [
      { jid: 'secretroom@example.com', password: 'password' },
      { jid: 'mainhall@example.com' }
    ]
  end

  let(:targets) do
    {
      rooms: rooms,
      users: ['one@example.com', 'two@example.com']
    }
  end

  describe '#process' do
    before do
      payload['build']['config']['notifications'] = { xmpp: { jid: 'travis', password: 'travis_password' } }
    end

    it 'instanciates a Client' do
      Travis::Addons::Xmpp::Client.expects(:new)
        .with('travis', 'travis_password').returns(client)
      subject.new(payload, targets: targets).send(:process)
    end
  end
end
