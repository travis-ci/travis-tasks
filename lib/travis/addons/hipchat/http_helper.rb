module Travis
  module Addons
    module Hipchat
      class HttpHelper
        require 'json'
        require 'open-uri'

        API_V1_TOKEN_LENGTH = 30
        API_V2_TOKEN_LENGTH = 40
        UNSAFE_URL_CHARS = Regexp.union([URI::Parser.new.regexp[:UNSAFE], /[\$&\+,\/:;=\?@~\[\]]/])

        attr_reader :api_version, :headers, :url, :token, :room_id

        # specification can be either of:
        #
        # - api_token (API V1)
        # - api_token@hipchat_room_name_or_id
        # - api_token@hostname/hipchat_room_name_or_id
        def initialize(specification)
          @token, @hostname, @room_id = specification.split(%r(@|/), 3)

          if @room_id.nil?
            @room_id = @hostname
            @hostname = 'api.hipchat.com'
          end

          case token.length
          when API_V1_TOKEN_LENGTH
            @api_version = 'v1'
            @url = 'https://%s/v1/rooms/message?format=json&auth_token=%s' % [ @hostname, token ]
            @headers = {}
          when API_V2_TOKEN_LENGTH
            @api_version = 'v2'
            @url = 'https://%s/v2/room/%s/notification?auth_token=%s' % [ @hostname, encode(@room_id), token]
            @headers = { 'Content-type' => 'application/json' }
          end
        end

        def add_content_type!(base_headers)
          base_headers.merge! headers
        end

        def body(info)
          case api_version
          when 'v1'
            { room_id: room_id, message: info[:line], color: info[:color], from: 'Travis CI', message_format: info[:message_format] }
          when 'v2'
            { message: info[:line], color: info[:color], message_format: info[:message_format], notify: info[:notify] }.to_json
          end
        end

        def encode(str)
          URI::encode(str, UNSAFE_URL_CHARS)
        end

      end
    end
  end
end
