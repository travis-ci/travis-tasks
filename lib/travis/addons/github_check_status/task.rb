require 'travis/github_apps'

module Travis
  module Addons
    module GithubCheckStatus
      class Task < Travis::Task
        STATUS = {
          'created'  => 'queued',
          'queued'   => 'queued',
          'started'  => 'in_progress',
          'passed'   => 'completed',
          'failed'   => 'completed',
          'errored'  => 'completed',
          'canceled' => 'completed',
        }

        CONCLUSION = {
          'passed'   => 'success',
          'failed'   => 'failure',
          'errored'  => 'action_required',
          'canceled' => 'neutral',
        }

        private

        def process(timeout)
          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]}")

          ## DO STUFF
          github_apps.post_with_app(url, payload)
        end

        def url
          "/repos/#{repository[:slug]}/check-runs"
        end

        def headers
          {
            "Accept" => "application/vnd.github.antiope-preview+json"
          }
        end

        def github_apps
          @github_apps ||= Travis::GitHubApps.new(accept_header: headers)
        end

        def installation_id
          params.fetch(:installation)
        end

        def access_token
          github_apps.access_token(installation_id)
        end

        ## Convenience methods for building the GitHub Check API payload
        def status
          STATUS[build[:state]]
        end

        def conclusion
          CONCLUSION[build[:state]]
        end

        def details_url
          # needs URL for this build's results
        end

        def external_id
          # ?
        end

        def completed_at
          build[:finished_at]
        end

        def title
          "Travis CI check"
        end

        def summary
          ""
        end

        def text
          ""
        end

        def output
          {
            title: title,
            summary: summary,
            text: text,
            # annotations: [],
            # images: []
          }
        end

        def payload
          data = {
            name: "Travis CI",
            details_url: details_url,
            external_id: external_id,
            status: status,
            output: output
          }

          if status == 'completed'
            data.merge!({conclusion: conclusion, completed_at: completed_at})
          end

          data
        end
      end
    end
  end
end