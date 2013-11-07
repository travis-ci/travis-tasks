require "spec_helper"
require "travis/notifications/notifiers/github_status"

describe Travis::Notifications::Notifiers::GitHubStatus do
  let(:payload) { notification_payload }
  let(:params) { { targets: ["abcdef12345"] } }
  subject(:github_status) { described_class.new(payload, params) }

  before(:each) do
    allow(GH).to receive(:with) { |&block| block.call }
    allow(GH).to receive(:post)
  end

  it "posts the message" do
    expect(GH).to receive(:post).with("/repos/green-eggs/ham/statuses/abcdef", state: "success", description: "The Travis CI build passed", target_url: "https://travis-ci.org/green-eggs/ham/builds/3")

    github_status.run
  end
end
