module Travis
  module Notifications
    module TestPayloads
      MASTER_PAYLOAD = {
        repository: {
          id: 1,
          key: nil,
          slug: 'green-eggs/ham',
          owner_email: 'jane@example.com',
          owner_avatar_url: 'https://avatars.example.com/jane',
        },
        request: {
          token: 'foobarbaz',
          head_commit: 'abcdef',
        },
        commit: {
          id: 2,
          sha: 'abcdef',
          branch: 'master',
          message: 'Initial commit',
          committed_at: '2013-10-27T12:34:56Z',
          author_name: 'Jane Doe',
          author_email: 'jane@example.com',
          committer_name: 'Jane Doe',
          committer_email: 'jane@example.com',
          committer_email: 'jane@example.com',
          compare_url: 'http://travis.example.com/compare/1',
        },
        build: {
          id: 3,
          repository_id: 1,
          commit_id: 2,
          number: '1',
          pull_request: false,
          config: {
            language: 'ruby',
            rvm: '2.0.0',
            notifications: {
              flowdock: 'abcdef12345',
              campfire: 'example:foobar@1234',
            },
          },
          state: 'passed',
          previous_state: 'failed',
          started_at: '2013-10-27T12:35:00Z',
          finished_at: '2013-10-27T12:36:00Z',
          duration: 60,
          job_ids: [4],
        },
        jobs: [{
          id: 4,
          number: '1',
          state: 'passed',
          tags: [],
        }],
      }

      def notification_payload
        # Do a deep clone so modifying the payload only affects a single test
        Marshal.load(Marshal.dump(MASTER_PAYLOAD))
      end
    end
  end
end

RSpec.configure do |c|
  c.include Travis::Notifications::TestPayloads
end
