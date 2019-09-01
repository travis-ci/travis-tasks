require 'json'
require 'travis/remote_vcs/client'

module Travis
  class RemoteVCS
    class Repository < Client
      def check_runs(vcs_id, commit, check_run_name)
        connection.get do |req|
          req.url "/repos/#{vcs_id}/checks"
          req.params['commit'] = commit
          req.params['check_name'] = check_run_name
        end
      end

      def create_check_run(vcs_id, payload)
        connection.post do |req|
          req.url "/repos/#{vcs_id}/checks"
          req.params['payload'] = payload
        end
      end

      def update_check_run(vcs_id, id, payload)
        connection.post do |req|
          req.url "/repos/#{vcs_id}/checks"
          req.params['id'] = id
          req.params['payload'] = payload
        end
      end
    end
  end
end
