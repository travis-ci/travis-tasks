require "spec_helper"
require "travis/notifications/notifiers/campfire"

describe Travis::Notifications::Notifiers::Campfire do
  let(:http) { double("http", post: nil, basic_auth: nil) }
  let(:payload) { notification_payload }
  let(:params) { { targets: ["example:foobar@1234"] } }
  subject(:campfire) { described_class.new(payload, params) }

  before(:each) do
    allow(Faraday).to receive(:new).and_return(http)
  end

  it "posts each message" do
    request = double("request", :body= => nil, :headers => {})
    allow(http).to receive(:post).and_yield(request)

    expect(http).to receive(:post).with("https://example.campfirenow.com/room/1234/speak.json").exactly(3).times
    expect(request).to receive(:body=).with('{"message":{"body":"[travis-ci] green-eggs/ham#1 (master - abcdef : Jane Doe): the build has passed"}}')
    expect(request).to receive(:body=).with('{"message":{"body":"[travis-ci] Change view: http://travis.example.com/compare/1"}}')
    expect(request).to receive(:body=).with('{"message":{"body":"[travis-ci] Build details: http://travis-ci.org/green-eggs/ham/builds/3"}}')

    campfire.run
  end

  it "authenticates with the token" do
    expect(http).to receive(:basic_auth).with("foobar", anything())

    campfire.run
  end

  context "with multiple targets" do
    before(:each) do
      params[:targets] = ["example:foobar@1234", "other:barbaz@2345"]
    end

    it "posts to each target" do
      expect(http).to receive(:post).with("https://example.campfirenow.com/room/1234/speak.json").exactly(3).times
      expect(http).to receive(:post).with("https://other.campfirenow.com/room/2345/speak.json").exactly(3).times

      campfire.run
    end
  end

  context "with custom template" do
    before(:each) do
      payload[:build][:config][:notifications][:campfire] = {
        rooms: "example:foobar@1234",
        template: "%{repository} (%{commit}): %{message}"
      }
    end

    it "uses the given template instead of the default" do
      request = double("request", :body= => nil, :headers => {})
      allow(http).to receive(:post).and_yield(request)

      expect(request).to receive(:body=).with('{"message":{"body":"green-eggs/ham (abcdef): The build was fixed."}}')

      campfire.run
    end
  end
end
