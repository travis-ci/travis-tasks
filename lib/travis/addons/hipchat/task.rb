module Travis
  module Addons
    module Hipchat

      # Publishes a build notification to hipchat rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Hipchat credentials can be encrypted using the repository's ssl key.
      class Task < Travis::Task
        require 'travis/addons/hipchat/http_helper'

        DEFAULT_TEMPLATE = [
          "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
          "Change view: %{compare_url}",
          "Build details: %{build_url}"
        ]

        def targets
          params[:targets]
        end

        def message
          @messages ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

          def process(timeout)
            targets.each do |target|
              helper = HttpHelper.new(target)
              if helper.url.nil?
                error "Empty HipChat URL for #{repository[:slug]}##{build[:id]}, decryption probably failed."
                next
              end

              send_message(helper, message, timeout = timeout)

            end
          end

          def send_message(helper, message, timeout)
            message.each do |line|
              response = http.post(helper.url) do |r|
                r.options.timeout = timeout
                r.body = helper.body(line: line, color: color, message_format: message_format, notify: notify)
                helper.add_content_type!(r.headers)
              end

              if not response.success?
                error "task=hipchat build=#{build[:id]} room=#{helper.room_id} message=#{response.body["error"].try(:[], "message")}"
              end
            end
          end

          def template
            template = config[:template] rescue nil
            Array(template || DEFAULT_TEMPLATE)
          end

          def notify
            (config[:notify] rescue nil) || false
          end

          def color
            {
              "passed" => "green",
              "failed" => "red",
              "errored" => "red",
              "canceled" => "gray",
            }.fetch(build[:state], "yellow")
          end

          def message_format
            (config[:format] rescue nil) || 'text'
          end

          def config
            build[:config][:notifications][:hipchat] rescue {}
          end
      end
    end
  end
end

