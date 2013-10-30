require "spec_helper"
require "travis/notifications/notifiers/flowdock"

describe Travis::Notifications::Notifiers::Flowdock do
  let(:http) { double("http", post: nil) }
  let(:payload) do
    {
      repository: {
        id: 1,
        key: nil,
        slug: "green-eggs/ham",
        owner_email: "jane@example.com",
        owner_avatar_url: "https://avatars.example.com/jane",
      },
      request: {
        token: "foobarbaz",
        head_commit: "abcdef",
      },
      commit: {
        id: 2,
        sha: "abcdef",
        branch: "master",
        message: "Initial commit",
        committed_at: "2013-10-27T12:34:56Z",
        author_name: "Jane Doe",
        author_email: "jane@example.com",
        committer_name: "Jane Doe",
        committer_email: "jane@example.com",
        committer_email: "jane@example.com",
        compare_url: "http://travis.example.com/compare/1",
      },
      build: {
        id: 3,
        repository_id: 1,
        commit_id: 2,
        number: "1",
        pull_request: false,
        config: {
          language: "ruby",
          rvm: "2.0.0",
          notifications: {
            flowdock: "abcdef12345",
          },
        },
        state: "passed",
        previous_state: "failed",
        started_at: "2013-10-27T12:35:00Z",
        finished_at: "2013-10-27T12:36:00Z",
        duration: 60,
        job_ids: [4],
      },
      jobs: [{
        id: 4,
        number: "1",
        state: "passed",
        tags: [],
      }],
    }
  end
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
