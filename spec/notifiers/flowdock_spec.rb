require "spec_helper"
require "travis/notifications/notifiers/flowdock"

describe Travis::Notifications::Notifiers::Flowdock do
  let(:http) { double("http", post: nil) }
  let(:payload) { notification_payload }
  let(:params) { { targets: ["abcdef12345"] } }
  subject(:flowdock) { described_class.new(payload, params) }

  before(:each) { allow(Faraday).to receive(:new).and_return(http) }

  it "posts the message" do
    request = double("request", :body= => nil, :headers => {})
    allow(http).to receive(:post).and_yield(request)

    expect(http).to receive(:post).with("https://api.flowdock.com/v1/messages/team_inbox/abcdef12345")
    expect(request).to receive(:body=).with(/build #1 has passed/)

    flowdock.run
  end

  context "with multiple targets" do
    before(:each) do
      params[:targets] = ["abcdef12345", "fedcba54321"]
    end

    it "posts to each target" do
      expect(http).to receive(:post).with("https://api.flowdock.com/v1/messages/team_inbox/abcdef12345")
      expect(http).to receive(:post).with("https://api.flowdock.com/v1/messages/team_inbox/fedcba54321")

      flowdock.run
    end
  end
end
