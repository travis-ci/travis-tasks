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

        def url
          "/repos/#{repository[:slug]}/statuses/#{sha}"
        end

        private

          def process(timeout)
            info("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} tokens_count=#{tokens.size}")

            tokens.each do |username, token|
              if process_with_token(username, token)
                return
              else
                error("type=github_status build=#{build[:id]} repo=#{repository[:slug]} error=not_updated commit=#{sha} username=#{username} url=#{GH.api_host + url}")
              end
            end
          end

          def tokens
            params.fetch(:tokens) { { '<legacy format>' => params[:token] } }
          end

          def process_with_token(username, token)
            authenticated(token) do
              GH.post(url, :state => state, :description => description, :target_url => target_url, :context => context)
            end
          rescue GH::Error(:response_status => 401) => e
            error("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} username=#{username} response_status=401 reason=incorrect_auth body=#{e.info[:response_body]}")
            nil
          rescue GH::Error(:response_status => 403) => e
            error("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} username=#{username} response_status=403 reason=incorrect_auth_or_suspended_acct body=#{e.info[:response_body]}")
            nil
          rescue GH::Error(:response_status => 404) => e
            error("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} username=#{username} response_status=404 reason=repo_not_found_or_incorrect_auth body=#{e.info[:response_body]}")
            nil
          rescue GH::Error(:response_status => 422)
            error("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha} username=#{username} response_status=422 reason=maximum_number_of_statuses")
            nil
          rescue GH::Error => e
            message = "type=github_status build=#{build[:id]} repo=#{repository[:slug]} error=not_updated commit=#{sha} url=#{GH.api_host + url} message=#{e.message}"
            error(message)
            raise message
          end

          def target_url
            with_utm("#{Travis.config.http_host}/#{repository[:slug]}/builds/#{build[:id]}", :github_status)
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

          def authenticated(token, &block)
            GH.with(http_options(token), &block)
          end

          def http_options(token)
            super().merge(token: token, headers: headers, ssl: (Travis.config.github.ssl || {}).to_hash.compact)
          end

          def headers
            {
              "Accept" => "application/vnd.github.v3+json"
            }
          end
      end
    end
  end
end
