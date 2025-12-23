require 'spec_helper'

describe Travis::Addons::Msteams::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Msteams::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) do
    {
      type: 'message',
      attachments: [{
        contentType: 'application/vnd.microsoft.card.adaptive',
        content: {
          type: 'AdaptiveCard',
          version: '1.5',
          body: [{ type: 'TextBlock', text: 'Build passed' }]
        }
      }]
    }
  end

  before do
    subject.any_instance.unstub(:http)
    subject.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    task_payload = Marshal.load(Marshal.dump(TASK_PAYLOAD))
    subject.new(task_payload, targets: targets, payload: payload).run
  end

  it 'sends notifications to MS Teams webhook URLs' do
    targets = ['https://outlook.office.com/webhook/test1', 'https://outlook.office.com/webhook/test2']

    targets.each do |target|
      http.post(target) do |env|
        expect(env[:request_headers]['Content-Type']).to eq('application/json')
        expect(MultiJson.decode(env[:body])).to eq(payload.deep_stringify_keys)
        [200, {}, '1']
      end
    end

    run(targets)
    http.verify_stubbed_calls
  end

  it 'handles invalid URIs gracefully' do
    targets = ['not-a-valid-url']
    expect { run(targets) }.to_not raise_error
  end

  it 'handles HTTP errors gracefully' do
    target = 'https://outlook.office.com/webhook/test'

    http.post(target) do |env|
      [500, {}, 'Internal Server Error']
    end

    expect { run([target]) }.to_not raise_error
    http.verify_stubbed_calls
  end

  it 'masks sensitive information in logs' do
    task_instance = subject.new(TASK_PAYLOAD, targets: [], payload: payload)
    url = 'https://outlook.office.com/webhook/abc123def456/IncomingWebhook/xyz789/unique-token-here'

    masked = task_instance.send(:mask_url, url)
    expect(masked).to_not include('abc123def456')
    expect(masked).to_not include('unique-token-here')
    expect(masked).to include('***')
  end
end
