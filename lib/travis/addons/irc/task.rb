module Travis
  module Addons
    module Irc

      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Task < Travis::Task
        DEFAULT_TEMPLATE = [
          "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
          "Change view : %{compare_url}",
          "Build details : %{build_url}"
        ]

        def channels
          @channels ||= params[:channels]
          # @channels ||= options[:channels].inject({}) do |channels, (key, value)|
          #   key = eval(key) if key.is_a?(String)
          #   channels.merge(key => value)
          # end
        end

        def messages
          @messages ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

          def process(timeout)
            # Notifications to the same host are grouped so that they can be sent with a single connection
            parsed_channels.each do |server, channels|
              host, port, ssl = *server
              send_messages(host, port, ssl, channels)
            end
          end

          def send_messages(host, port, ssl, channels)
            client(host, nick, client_options(host, port, ssl)) do |client|
              channels.each do |channel|
                addr = "#{host}:#{port}##{channel}"
                if freenode?(host) && freenode_blocked?(channel)
                  info("Skipping blocked #{addr}")
                  next
                end

                begin
                  send_message(client, channel)
                  info("Successfully notified #{addr}")
                rescue StandardError => e
                  # TODO notify the repo
                  error("Could not notify #{addr}: #{e.inspect}")
                end
              end
            end
          rescue StandardError => e
            # TODO notify the repo
            error("Could not connect to #{host}: #{e.inspect}")
          end

          def send_message(client, channel)
            channel, key = channel.split ',', 2
            client.join(channel, key || try_config(:channel_key) || nil) if join?
            messages.each { |message| client.say(message, channel, notice?) }
            client.leave(channel) if join?
          end

          # TODO move parsing irc urls to irc client class
          def parsed_channels
            channels.inject(Hash.new([])) do |servers, url|
              begin
                uri = Addressable::URI.heuristic_parse(url, :scheme => 'irc')
                ssl = uri.scheme == 'irc' ? nil : :ssl
                servers[[uri.host, uri.port, ssl]] += [URI.decode(uri.fragment)]
                servers
              rescue
                {}
              end
            end
          end

          def notice?
            !!try_config(:use_notice)
          end

          def join?
            !try_config(:skip_join)
          end

          def template
            Array(params[:template] || try_config(:template) || DEFAULT_TEMPLATE)
          end

          def client_options(host, port, ssl)
            options = {
              :port => port,
              :ssl => (ssl == :ssl),
              :password => try_config(:password),
              :nickserv_password => try_config(:nickserv_password),
            }

            freenode_password = Travis.config.irc.try(:freenode_password)
            if freenode_password && freenode?(host)
              options[:password] = freenode_password
              options[:nickserv_password] = freenode_password
              options[:sasl] = true
            end

            options
          end

          def client(host, nick, options, &block)
            client = Client.new(host, nick, options)
            client.wait_for_numeric
            client.run(&block) if block_given?
            client.quit
          end

          def nick
            try_config(:nick) || Travis.config.irc.try(:nick) || 'travis-ci'
          end

          def freenode?(host)
            (host.end_with?('.freenode.net') || host.end_with?('.freenode.org')) && nick == 'travis-ci'
          end

          def freenode_blocked?(channel)
            Array(Travis.config.irc.freenode_blocked_channels).include?(channel)
          end

          def try_config(option)
            config.is_a?(Hash) and config[option]
          end

          def config
            build[:config][:notifications][:irc] || {} rescue {}
          end
      end
    end
  end
end
