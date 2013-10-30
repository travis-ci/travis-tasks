require "spec_helper"
require "travis/notifications/notifiers/github_status"

describe Travis::Notifications::Notifiers::GitHubStatus do
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
