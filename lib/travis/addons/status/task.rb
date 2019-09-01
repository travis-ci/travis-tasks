module Travis
  module Addons
    module GithubStatus
      class Task < Travis::Task
      private

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

        def url
          "/repos/#{repository[:slug]}/statuses/#{sha}"
        end

        # Adds a comment with a build notification to the Pull Request the request belongs to.
        def process(timeout)
          info("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} installation_id=#{installation_id}")

          resp = create_status
          if resp.success?
            info("type=github_status repo=#{repository[:slug]} response_status=#{resp.status}")
          else
            reason = ERROR_REASONS[resp.status]
            message = "type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} installation_id=#{installation_id} response_status=#{resp.status} reason=#{reason} body=#{resp.body}"
            error(message)
            raise message if reason.nil?
          end
        end

        def create_status
          Travis::RemoteVCS::Repository.new.create_status(repository[:github_id], sha, status_payload.to_json)
        end

        def target_url
          with_utm("#{Travis.config.http_host}/#{repository[:slug]}/builds/#{build[:id]}", :github_status)
        end

        def status_payload
          {
            state: state,
            description: DESCRIPTIONS[state],
            target_url: target_url,
            context: context
          }
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
      end
    end
  end
end
