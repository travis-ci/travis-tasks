# Very (maybe too) simple IRC client that is used for IRC notifications.
#
# based on:
# https://github.com/sr/shout-bot
#
# other libs to take note of:
# https://github.com/tbuehlmann/ponder
# https://github.com/cinchrb/cinch
# https://github.com/cho45/net-irc
require 'socket'
require 'openssl'

module Travis
  module Addons
    module Irc
      class Client
        attr_accessor :channel, :socket, :ping_thread, :numeric_received, :connection_info

        def self.wrap_ssl(socket)
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE # TODO!
          OpenSSL::SSL::SSLSocket.new(socket, ssl_context).tap do |sock|
            sock.sync = true
            sock.connect
          end
        end

        def initialize(server, nick, options = {})
          @connection_info = "host=#{server} port=#{options[:port] || 6667} nick=#{nick} protocol=#{options[:ssl] ? 'ircs' : 'irc'}"
          @socket = TCPSocket.open(server, options[:port] || 6667)
          @socket = self.class.wrap_ssl(@socket) if options[:ssl]
          @ping_thread = start_ping_thread

          Travis.logger.info("task=irc message=connection_init #{connection_info}")

          socket.puts "PASS #{options[:password]}\r" if options[:password]
          socket.puts "NICK #{nick}\r"
          socket.puts "PRIVMSG NickServ :IDENTIFY #{options[:nickserv_password]}\r" if options[:nickserv_password]
          socket.puts "USER #{nick} #{nick} #{nick} :#{nick}\r"
        end

        def wait_for_numeric
          # Loop until we get a numeric (second word is a 3-digit number).
          Timeout.timeout(60) do
            loop do
              break if @numeric_received
            end
          end
        rescue Timeout::Error => e
          Travis.logger.warn("task=irc message=conntection_timeout #{connection_info}")
        end

        def join(channel, key = nil)
          socket.puts("JOIN ##{channel} #{key}".strip + "\r")
        end

        def run(&block)
          yield(self) if block_given?
        end

        def leave(channel)
          socket.puts "PART ##{channel}\r"
        end

        def say(message, channel, use_notice = false)
          message_type = use_notice ? "NOTICE" : "PRIVMSG"
          socket.puts "#{message_type} ##{channel} :#{message}\r"
        end

        def quit
          socket.puts "QUIT\r"
          until socket.eof? do
            res = socket.gets
            log_level = res.split[1] =~ /[45]\d\d/ ? Logger::ERROR : Logger::DEBUG
            Travis.logger.log(log_level, "task=irc message=#{res}")
          end
          socket.close
          ping_thread.exit
        end

        private

          def start_ping_thread
            Thread.new(socket) do |s|
              loop do
                case s.gets
                when /^PING (.*)/
                  # PING received
                  s.puts "PONG #{$1}\r"
                when /^:\S+ \d{3} .*$/
                  # Numeric received (second word is a 3-digit number).
                  @numeric_received = true
                end
                sleep 0.2
              end
            end
          end
      end
    end
  end
end

