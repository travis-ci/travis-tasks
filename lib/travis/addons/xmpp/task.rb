module Travis
  module Addons
    module Xmpp
      class Task < Travis::Task
        DEFAULT_TEMPLATE = [
          "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
          "Change view: %{compare_url}",
          "Build details: %{build_url}"
        ]

        def messages
          @messages ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

        def process
          Client.new(jid, password).run do |client|
            process_rooms(client)
            process_users(client)
          end
        end

        def process_rooms(client)
          room_targets.each do |room_data|
            client.join_room(room_data[:jid], room_data[:password])
            messages.each { |message| client.send_room(message) }
            client.quit_room
          end
        end

        def process_users(client)
          user_targets.each do |user_jid|
            messages.each { |message| client.send_user(user_jid, message) }
          end
        end

        def template
          Array(config[:template] || DEFAULT_TEMPLATE)
        end

        def jid
          config[:jid]
        end

        def password
          config[:password]
        end

        def config
          build[:config][:notifications][:xmpp] rescue {}
        end

        def room_targets
          targets[:rooms] || []
        end

        def user_targets
          targets[:users] || []
        end

        def targets
          params[:targets]
        end
      end
    end
  end
end
