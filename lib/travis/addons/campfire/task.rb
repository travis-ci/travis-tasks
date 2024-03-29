require 'multi_json'

module Travis
  module Addons
    module Campfire

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class Task < Travis::Task
        DEFAULT_TEMPLATE = [
          "[travis-ci] %{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
          "[travis-ci] Change view: %{compare_url}",
          "[travis-ci] Build details: %{build_url}"
        ]

        def targets
          params[:targets]
        end

        def message
          @message ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

          def process(timeout)
            targets.each { |target| send_message(target, message, timeout) }
          end

          def http_call(url, params = {})
          @http_call ||= Faraday.new(http_options.merge(url: url)) do |f|
            f.request :url_encoded
            f.response :follow_redirects
            f.headers["User-Agent"] = user_agent_string
            f.request :authorization, :basic, params[:basic_auth][:user], params[:basic_auth][:pass] if params.include?(:basic_auth)
            f.adapter :net_http
          end
        end

          def send_message(target, lines, timeout)
            url, token = parse(target)
            connection = http_call(base_url(url), { basic_auth: { user: token, pass: 'X'}})
            lines.each { |line| send_line(connection, url, line, timeout) }
          rescue => e
            Travis.logger.info("Error connecting to Campfire service for #{target}: #{e.message}")
          end

          def send_line(connection, url, line, timeout)
            connection.post(url) do |r|
              r.options.timeout = timeout
              r.body = MultiJson.encode({ message: { body: line } })
              r.headers['Content-Type'] = 'application/json'
            end
          end

          def template
            template = params[:template] || config[:template] rescue nil
            Array(template || DEFAULT_TEMPLATE)
          end

          def parse(target)
            target =~ /([\w-]+):([\w-]+)@(\d+)/
            ["https://#{$1}.campfirenow.com/room/#{$3}/speak.json", $2]
          end

          def config
            build[:config][:notifications][:campfire] rescue {}
          end
      end
    end
  end
end
