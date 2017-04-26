describe Travis::Task::Keenio do
  let(:type)    { :email }
  let(:status)  { :success }
  let(:data)    { described_class.new(type, status, payload).data }
  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)).deep_symbolize_keys }

  it { expect(data[:type]).to              eq :email }
  it { expect(data[:status]).to            eq :success }

  it { expect(data[:repository][:id]).to   eq 1 }
  it { expect(data[:repository][:slug]).to eq 'svenfuchs/minimal' }

  it { expect(data[:owner][:id]).to        eq 1 }
  it { expect(data[:owner][:type]).to      eq 'User' }
  it { expect(data[:owner][:login]).to     eq 'login' }

  it { expect(data[:build][:id]).to        eq 1 }
  it { expect(data[:build][:type]).to      eq 'push' }
end
