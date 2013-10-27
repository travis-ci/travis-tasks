require "addressable/uri"
require "irc-notify"
require "travis/tasks/util/template"
require "travis/tasks/notifier"

module Travis
  module Tasks
    module Notifiers
      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Irc < Notifier
        DEFAULT_TEMPLATE = [
          "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
          "Change view : %{compare_url}",
          "Build details : %{build_url}"
        ]

        def channels
          @channels ||= params[:channels]
        end

        def messages
          @messages ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

          def process
            # Notifications to the same host are grouped so that they can be sent with a single connection
            parsed_channels.each do |server, channels|
              host, port, ssl = *server
              send_messages(host, port, ssl, channels)
            end
          end

          def send_messages(host, port, ssl, channels)
            client = IrcNotify::Client.build(host, port, ssl: ssl == :ssl)
            client.register(nick, password: try_config(:password), nickserv_password: try_config(:nickserv_password)))
            channels.each do |channel|
              send_message(client, channel)
            end
          rescue StandardError => e
            error("Could not connect to #{host}: #{e.inspect}")
          end

          def send_message(client, channel)
            client.notify(
              channel,
              messages.map { |message| "[travis-ci] #{message}" }.join("\n"), channel_key: try_config(:channel_key),
              join: join?,
              notice: notice?
            )
            info("Successfully notified #{host}:#{port}#{channel}")
          rescue StandardError => e
            info("Could not notify #{channel}: #{e.inspect}")
          end

          # TODO move parsing irc urls to irc client class
          def parsed_channels
            channels.inject(Hash.new([])) do |servers, url|
              uri = Addressable::URI.heuristic_parse(url, :scheme => 'irc')
              ssl = uri.scheme == 'irc' ? nil : :ssl
              servers[[uri.host, uri.port, ssl]] += [uri.fragment]
              servers
            end
          end

          def notice?
            !!try_config(:use_notice)
          end

          def join?
            !try_config(:skip_join)
          end

          def template
            Array(try_config(:template) || DEFAULT_TEMPLATE)
          end

          def nick
            try_config(:nick) || Travis.config.irc.try(:nick) || 'travis-ci'
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

