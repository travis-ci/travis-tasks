require 'travis/support/instrumentation'
require 'travis/support/chunkifier'

module Travis
  module Addons
    module Pusher

      # Notifies registered clients about various state changes through Pusher.
      class Task < Travis::Task

        def self.chunk_size
          9 * 1024 + 100
        end

        def event
          params[:event]
        end

        def client_event
          @client_event ||= (event =~ /job:.*/ ? event.gsub(/(test|configure):/, '') : event)
        end

        def channels
          channels = private_channels? ? ["repo-#{repo_id}"] : ['common']
          channels.map { |channel| [channel_prefix, channels].compact.join('-') }
        end

        private

          def process
            channels.each { |channel| trigger(channel, payload) }
          end

          def trigger(channel, payload)
            parts(payload).each do |part|
              begin
                Travis.pusher[channel].trigger(client_event, part)
              rescue ::Pusher::Error => e
                Travis.logger.error("[addons:pusher] Could not send event due to Pusher::Error: #{e.message}, event=#{client_event}, payload: #{part.inspect}")
                raise
              end
            end
          end

          def job_id
            payload[:id]
          end

          def repo_id
            # TODO api v1 is inconsistent here
            payload.key?(:repository) ? payload[:repository][:id] : payload[:repository_id]
          end

          def channel_prefix
            'private' if private_channels?
          end

          def private_channels?
            force_private_channels? || repository_private?
          end

          def force_private_channels?
            Travis.config.pusher.secure?
          end

          def repository_private?
            payload.key?(:repository) ? payload[:repository][:private] : payload[:repository_private]
          end

          def parts(payload)
            if client_event == 'job:log' && payload[:_log].present?
              # split payload into 9kB chunks, the limit is 10 for entire request
              # body, 1kB should be enough for headers
              log = payload[:_log]
              chunkifier = Chunkifier.new(log, chunk_size, :json => true)

              if chunkifier.length > 1
                # This should never happen when we update travis-worker to split log parts
                # bigger than 9kB.
                Travis.logger.warn("[addons:pusher] The log part from worker was bigger than 9kB (#{log.to_json.length}B), payload: #{payload.inspect}")
              end

              chunkifier.each_with_index.map do |part, i|
                new_payload = payload.dup.merge(:_log => part)
                new_payload[:number] = "#{new_payload[:number]}.#{i}" unless i == 0
                new_payload[:final] = new_payload[:final] && chunkifier.length - 1 == i
                new_payload
              end
            else
              [payload]
            end
          end

          def chunk_size
            self.class.chunk_size
          end
      end
    end
  end
end
