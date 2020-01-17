require 'travis/backends/vcs_client'

module Travis
  module Backends
    class Vcs < Travis::Backends::Base

      def name
        'vcs'
      end

      def create_check_run(id:, type:, payload:)
        client.post("/repos/#{CGI::escape(id)}/checks", vcs_type: type, payload: payload)
      end

      def update_check_run(id:, type:, check_run_id:, payload:)
        client.post("/repos/#{CGI::escape(id)}/checks", vcs_type: type, id: check_run_id, payload: payload)
      end

      def check_runs(id:, type:, ref:, check_run_name:)
        client.get("/repos/#{CGI::escape(id)}/checks", vcs_type: type, commit: ref, check_run_name: check_run_name)
      end

      def create_status(process_via_gh_apps:, id:, type:, ref:, payload:)
        client.post("/repos/#{CGI::escape(id)}/status", vcs_type: type, commit: ref, payload: payload)
      end

      def file_url(id:, type:, slug:, branch:, file:)
        response = client.get("/repos/#{CGI::escape(id)}/urls/file", vcs_type: type, branch: branch, file: file)
        JSON.parse(response.body)[:url] if response.success?
      end

      def branch_url(id:, type:, slug:, branch:)
        response = client.get("/repos/#{CGI::escape(id)}/urls/branch", vcs_type: type, branch: branch)
        Travis.logger.info("Result of /repos/#{CGI::escape(id)}/urls/branch: #{response.to_s}")
        JSON.parse(response.body)[:url] if response.success?
      end

      def create_check_run_url(id)
        "#{Travis.config.vcs.url}/repos/#{CGI::escape(id)}/checks"
      end

      def create_status_url(id, _ref)
        "#{Travis.config.vcs.url}/repos/#{CGI::escape(id)}/status"
      end

    private

      def client
        @client ||= Travis::Backends::VcsClient.new
      end
    end
  end
end
