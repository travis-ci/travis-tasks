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

          def process
            info("type=github_status build=#{build[:id]} repo=#{repository[:slug]} state=#{state} commit=#{sha}")

            tokens.each do |username, token|
              if process_with_token(token)
                return
              else
                error("type=github_status build=#{build[:id]} repo=#{repository[:slug]} error=not_updated commit=#{sha} username=#{username} url=#{GH.api_host + url}")
              end
            end
          end

          def tokens
            params.fetch(:tokens) { { '<legacy format>' => params[:token] } }
          end

          def process_with_token(token)
            authenticated(token) do
              GH.post(url, :state => state, :description => description, :target_url => target_url, :context => context)
            end
          rescue GH::Error(:response_status => 401)
            nil
          rescue GH::Error => e
            message = "type=github_status build=#{build[:id]} repo=#{repository[:slug]} error=not_updated commit=#{sha} url=#{GH.api_host + url} message=#{e.message}"
            error(message)
            response_status = e.info[:response_status]
            case response_status
            when 401, 422, 404
            else
              raise message
            end
          end

          def target_url
            "#{Travis.config.http_host}/#{repository[:slug]}/builds/#{build[:id]}"
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
            super().merge(token: token, headers: headers)
          end

          def headers
            {
              "Accept" => "application/vnd.github.she-hulk-preview+json"
            }
          end
      end
    end
  end
end

