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

      def create_status(vcs_id, commit, payload)
        connection.post do |req|
          req.url "/repos/#{vcs_id}/status"
          req.params['commit'] = commit
          req.params['payload'] = payload
        end
      end

      def branch_url(vcs_id, branch)
        resp = connection.post do |req|
          req.url "/repos/#{vcs_id}/urls/branch"
          req.params['branch'] = branch
        end
        JSON.parse(resp.body)[:url] if resp.success?
      end

      def file_url(vcs_id, branch, file)
        resp = connection.post do |req|
          req.url "/repos/#{vcs_id}/urls/file"
          req.params['branch'] = branch
          req.params['file'] = file
        end
        JSON.parse(resp.body)[:url] if resp.success?
      end
    end
  end
end
