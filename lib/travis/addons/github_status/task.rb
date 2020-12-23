module Travis
  module Addons
    module GithubStatus

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Task < Travis::Task
        STATES = {
          'created'  => 'pending',
          'queued'   => 'pending',
          'started'  => 'pending',
          'passed'   => 'success',
          'failed'   => 'failure',
          'errored'  => 'error',
          'canceled' => 'error',
        }

        DESCRIPTIONS = {
          'pending' => 'The Travis CI build is in progress',
          'success' => 'The Travis CI build passed',
          'failure' => 'The Travis CI build failed',
          'error'   => 'The Travis CI build could not complete due to an error',
        }

        ERROR_REASONS = {
          401 => :incorrect_auth,
          403 => :incorrect_auth_or_suspended_acct_or_rate_limited,
          404 => :repo_not_found_or_incorrect_auth,
          422 => :maximum_number_of_statuses,
        }

        REDIS_PREFIX = 'travis-tasks:github-status:'.freeze

        private

        def url
          client.create_status_url(repository[:vcs_id], sha)
        end

        def process(_timeout)
          client.create_status(
            id: repository[:vcs_id],
            type: repository[:vcs_type],
            ref: sha,
            pr_number: payload[:pull_request] && payload[:pull_request][:number],
            payload: status_payload
          )

          message = %W[
            type=github_status
            build=#{build[:id]}
            repo=#{repository[:slug]}
            state=#{state}
            commit=#{sha}
            installation_id=#{installation_id}
          ].join(' ')

          info("#{message} processed_with=#{client.name}")
        end

        def target_url
          with_utm("#{Travis.config.http_host}/#{Travis::Addons::Util::Helpers.vcs_prefix(repository[:vcs_type])}/#{repository[:vcs_slug] || repository[:slug]}/builds/#{build[:id]}", :github_status)
        end

        def status_payload
          {
            state: state,
            description: description,
            target_url: target_url,
            context: context
          }
        end

        def client
          @client ||= Travis::Api.backend(repository[:vcs_id], repository[:vcs_type], installation_id: installation_id)
        end

        def installation_id
          params.fetch(:installation, nil)
        end

        def sha
          pull_request? ? request[:head_commit] : commit[:sha]
        end

        def context
          build_type = pull_request? ? "pr" : "push"
          "continuous-integration/travis-ci/#{build_type}"
        end

        def state
          STATES[build[:state]]
        end

        def description
          DESCRIPTIONS[state]
        end
      end
    end
  end
end
