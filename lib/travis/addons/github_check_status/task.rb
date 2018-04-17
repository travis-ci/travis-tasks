require 'travis/github_apps'

module Travis
  module Addons
    module GithubCheckStatus
      class Task < Travis::Task

        private

        def headers
          {
            "Accept" => "application/vnd.github.antiope-preview+json"
          }
        end
      end
    end
  end
end