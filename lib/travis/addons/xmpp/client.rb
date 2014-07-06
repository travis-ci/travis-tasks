module Travis
  module Addons
    module Xmpp
      class Client
        require 'xmpp4r/client'
        require 'xmpp4r/muc/helper/simplemucclient'

        include Jabber

        attr_accessor :jid, :password, :client

        def initialize(jid, password)
          @jid           = ::Jabber::JID.new(jid)
          @password      = password
          @client        = ::Jabber::Client.new(jid)
        end

        def connect
          client.connect
          client.auth(password)
        end

        def join_room(room_jid, passord = nil)
          room_client.join(::Jabber::JID.new(room_jid), password)
        end

        # Send to Multi User Chatroom
        def send_room(message)
          room_client.say(message)
        rescue => e
          Travis.logger.error("Error sending message to XMPP room #{room_client.jid}: #{e.message}")
        end

        def quit_room
          room_client.exit
        end

        def send_user(recipient_jid, message)
          client.send(xmpp_message(recipient_jid, message))
        rescue => e
          Travis.logger.error("Error sending message to XMPP user #{recipient_jid}: #{e.message}")
        end

        def run(&block)
          connect
          yield(self) if block_given?
        ensure
          close
        end

        def close
          client.close
        end

        private

        def room_client
          @room_client ||= ::Jabber::MUC::SimpleMUCClient.new(client)
        end

        def xmpp_message(recipient_jid, message)
          jabber_message = ::Jabber::Message.new(recipient_jid, message)
          jabber_message.set_type(:headline)
          jabber_message
        end
      end
    end
  end
end
