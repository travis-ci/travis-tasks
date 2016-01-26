require 'multi_json'

module Travis
  module Addons
    module Pushover

      # Publishes a build notification to Pushover as defined in the
      # configuration (`.travis.yml`).
      #
      # Pushover API key and user key(s) are encrypted using the repository's ssl key.
      class Task < Travis::Task
        DEFAULT_TEMPLATE = "[travis-ci] %{repository}#%{build_number} (%{branch}): the build has %{result}. Details: %{build_url}"

        def message
          @message ||= Util::Template.new(template, payload).interpolate
        end

        def users
          params[:users]
        end

        def api_key
          params[:api_key]
        end

        private

          def process(timeout)
            token = api_key
            users.each { |user| send_message(user, message, token, timeout) }
          end

          def send_message(user, message, token, timeout)
            # this is roughly per https://pushover.net/faq#library-ruby
            msg_h = {:token => token, :user => user, :message => message}
            if is_failure
              msg_h[:sound] = 'falling'
            end
            http.post("https://api.pushover.net/1/messages.json") do |r|
              r.options.timeout = timeout
              r.body = msg_h
            end
          rescue => e
            Travis.logger.info("Error connecting to Pushover service for token #{token} user #{user}: #{e.message}")
          end

          def template
            template = config[:template] rescue nil
            template || DEFAULT_TEMPLATE
          end

          def is_failure
            ['failed', 'errored', 'canceled'].include? build[:state]
          end

          def config
            build[:config][:notifications][:pushover] rescue {}
          end
      end
    end
  end
end
