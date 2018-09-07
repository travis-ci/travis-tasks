require 'travis/addons/util/result_message'

module Travis
  module Addons
    module Webhook
      class Payload < Struct.new(:payload)
        def data
          {
            id:                  build[:id],
            number:              build[:number],
            config:              build[:config],
            type:                build[:type],
            state:               build[:state],
            status:              result(build),
            result:              result(build),
            status_message:      result_message(build),
            result_message:      result_message(build),
            started_at:          build[:started_at],
            finished_at:         build[:finished_at],
            duration:            build[:duration],
            build_url:           build_url,
            commit_id:           commit[:id],
            commit:              commit[:sha],
            base_commit:         request[:base_commit],
            head_commit:         request[:head_commit],
            branch:              commit[:branch],
            message:             commit[:message],
            compare_url:         commit[:compare_url],
            committed_at:        commit[:committed_at],
            author_name:         commit[:author_name],
            author_email:        commit[:author_email],
            committer_name:      commit[:committer_name],
            committer_email:     commit[:committer_email],
            pull_request:        pull_request?,
            pull_request_number: pull_request[:number],
            pull_request_title:  pull_request[:title],
            tag:                 tag[:name],
            repository:          repository_data,
            matrix:              jobs.map { |job| job_data(job) }
          }
        end

        def repository_data
          {
            id:         repo[:id],
            name:       repo[:name],
            owner_name: repo[:owner_name],
            url:        repo[:url]
          }
        end

        def job_data(job)
          {
            id:               job[:id],
            repository_id:    repo[:id],
            parent_id:        build[:id],
            number:           job[:number],
            state:            job[:state],
            config:           job[:config],
            status:           result(job),
            result:           result(job),
            commit:           commit[:sha],
            branch:           commit[:branch],
            message:          commit[:message],
            compare_url:      commit[:compare_url],
            started_at:       job[:started_at],
            finished_at:      job[:finished_at],
            committed_at:     commit[:committed_at],
            author_name:      commit[:author_name],
            author_email:     commit[:author_email],
            committer_name:   commit[:committer_name],
            committer_email:  commit[:committer_email],
            allow_failure:    job[:allow_failure]
          }
        end

        def build
          payload[:build] || {}
        end

        def repo
          payload[:repository] || {}
        end

        def request
          payload[:request] || {}
        end

        def commit
          payload[:commit] || {}
        end

        def pull_request
          payload[:pull_request] || {}
        end

        def tag
          payload[:tag] || {}
        end

        def jobs
          payload[:jobs] || []
        end

        def pull_request?
          build[:type] == 'pull_request'
        end

        def result(obj)
          case obj[:state].try(:to_sym)
          when :passed then 0
          when :failed, :errored then 1
          else nil
          end
        end

        def result_message(obj)
          Util::ResultMessage.new(obj).short
        end

        def build_url
          ["https://#{Travis.config[:host]}", repo[:slug], 'builds', build[:id]].join('/')
        end

        def format_date(date)
          date && date.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      end
    end
  end
end
