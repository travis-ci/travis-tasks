require 'gh'
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

        def url
          "/repos/#{repository[:slug]}/statuses/#{sha}"
        end

        private

          def process(timeout)
            users_tried = []
            status      = :not_ok
            message = %W[
              type=github_status
              build=#{build[:id]}
              repo=#{repository[:slug]}
              state=#{state}
              commit=#{sha}
              tokens_count=#{tokens.size}
            ].join(' ')

            while !tokens.empty? and status != :ok do
              username, token = tokens.shift
              unless token
                error("#{message} username=#{username} token=#{token.to_s}")
                next
              end

              status, details = process_with_token(username, token)
              if status == :ok
                info("#{message} username=#{username} processed_with=user_token token=#{token[0,3]}...")
                return
              elsif status == :skipped
                info "#{message} message=\"Token for #{username} failed within the last hour. Skipping\""
                next
              end

              # we can't post any more status to this commit, so there's
              # no point in trying further
              return if details[:status].to_i == 422

              users_tried << username
              error(%W[
                type=github_status
                build=#{build[:id]}
                repo=#{repository[:slug]}
                error=not_updated
                commit=#{sha}
                username=#{username}
                url=#{url}
                github_response=#{details[:status]}
                processed_with=user_token
                users_tried=#{users_tried}
                last_token_tried="#{token.to_s[0,3]}..."
                rate_limit=#{rate_limit_info details[:response_headers]}
                github_request_id=#{github_request_id details[:response_headers]}
              ].join(' '))
            end

            error("#{message} message=\"All known tokens failed to update status\"")
          end

          def tokens
            params.fetch(:tokens) { { '<legacy format>' => params[:token] } }
          end

          def process_with_token(username, token)
            Travis.redis_pool.with do |redis|
              if redis.exists(errored_token_key(token))
                return [:skipped, {}]
              end
            end

            value = authenticated(token) do
              GH.post(url, :state => state, :description => description, :target_url => target_url, :context => context)
            end
            [:ok, value]
          rescue GH::Error(:response_status => 401),
                 GH::Error(:response_status => 403),
                 GH::Error(:response_status => 404),
                 GH::Error(:response_status => 422) => e
            mark_token(username, token) if e.info[:response_status] == 403
            error(%W[
              type=github_status
              build=#{build[:id]}
              repo=#{repository[:slug]}
              state=#{state}
              commit=#{sha}
              username=#{username}
              response_status=#{e.info[:response_status]}
              reason=#{ERROR_REASONS.fetch(Integer(e.info[:response_status]))}
              processed_with=user_token
              body=#{e.info[:response_body]}
              last_token_tried="#{token.to_s[0,3]}..."
              rate_limit=#{rate_limit_info e.info[:response_headers]}
              github_request_id=#{github_request_id e.info[:response_headers]}
            ].join(' '))

            return [
              :error,
              {
                status: e.info[:response_status],
                reason: e.info[:response_body],
                response_headers: e.info[:response_headers]
                }
              ]
          rescue GH::Error => e
            message = %W[
              type=github_status
              build=#{build[:id]}
              repo=#{repository[:slug]}
              error=not_updated
              commit=#{sha}
              url=#{url}
              response_status=#{e.info[:response_status]}
              message=#{e.message}
              processed_with=user_token
              body=#{e.info[:response_body]}
              last_token_tried="#{token.to_s[0,3]}..."
              rate_limit=#{rate_limit_info e.info[:response_headers]}
              github_request_id=#{github_request_id e.info[:response_headers]}
            ].join(' ')
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
            GH.with(gh_no_tokencheck_stack.build(http_options(token)), &block)
          end

          def gh_no_tokencheck_stack
            return @gh_no_tokencheck_stack if @gh_no_tokencheck_stack
            @gh_no_tokencheck_stack = ::GH::Stack.new do
              use ::GH::Instrumentation
              use ::GH::Parallel
              use ::GH::Pagination
              use ::GH::LinkFollower
              use ::GH::MergeCommit
              use ::GH::LazyLoader
              use ::GH::Normalizer
              use ::GH::CustomLimit
              use ::GH::Remote
            end

            @gh_no_tokencheck_stack.options.merge! ::GH::DefaultStack.options
            @gh_no_tokencheck_stack
          end

          def http_options(token)
            super().merge(token: token, headers: headers, ssl: (Travis.config.github.ssl || {}).to_hash.compact)
          end

          def headers
            {
              "Accept" => "application/vnd.github.v3+json"
            }
          end

          def github_request_id(headers)
            if headers.respond_to? :[]
              headers["x-github-request-id"]
            end
          end

          def rate_limit_info(headers)
            return {error: "headers were nil"} unless headers

            unless rate_limit_headers_complete? headers
              return {error: "response headers did not contain rate limit information"}
            end

            {
              limit: headers["x-ratelimit-limit"].to_i,
              remaining: headers["x-ratelimit-remaining"].to_i,
              next_limit_reset_in: headers["x-ratelimit-reset"].to_i - Time.now.to_i
            }
          end

          def rate_limit_headers_complete?(headers)
            !headers.nil? &&
            !headers["x-ratelimit-limit"    ].to_s.empty? &&
            !headers["x-ratelimit-remaining"].to_s.empty? &&
            !headers["x-ratelimit-reset"    ].to_s.empty?
          end

          def github_request_id(headers)
            if headers.respond_to? :[]
              headers["x-github-request-id"]
            end
          end

          def errored_token_key(token)
            token_hash = Digest::SHA256.hexdigest(token)
            REDIS_PREFIX + "errored_tokens:#{token_hash}"
          end

          def mark_token(login, token)
            info "message=\"A request with token belonging to #{login} failed. Will skip using this token for 1 hour.\""
            Travis.redis_pool.with do |redis|
              redis.set errored_token_key(token), "", ex: 60*60 # an hour
            end
          end
      end
    end
  end
end
