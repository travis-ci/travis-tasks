require 'travis/remote_vcs/client'

module Travis
  class RemoteVCS
    class Status < Client
      def post(repository_id, payload)
        request(:post, __method__) do |req|
          req.url "repos/#{repository_id}/status"
          req.params = payload
        end
      end
    end
  end
end
