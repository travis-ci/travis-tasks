require "travis/notifications/notifier"

module Travis
  module Notifications
    module Notifiers
      # Notifies registered clients about various state changes through Pusher.
      class Pusher < Notifier
        def event
          params[:event]
        end

        def client_event
          @client_event ||= (event =~ /job:.*/ ? event.gsub(/(test|configure):/, '') : event)
        end

        def channels
          case client_event
          when 'job:log'
            ["job-#{payload[:id]}"]
          else
            ['common']
          end
        end

        private

          def process
            channels.each { |channel| trigger(channel, payload) }
          end

          def trigger(channel, payload)
            Travis.pusher[channel].trigger(client_event, payload)
          rescue ::Pusher::Error => e
            Travis.logger.error("[notifiers:pusher] Could not send event due to Pusher::Error: #{e.message}, event=#{client_event}, payload: #{payload.inspect}")
            raise
          end
      end
    end
  end
end

