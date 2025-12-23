module Travis
  module Addons
    module Msteams
      class Task < Travis::Task

        def process(timeout)
          targets.each do |target|
            send_notification(target, timeout)
          end
        end

        private

        def send_notification(url, timeout)
          body = payload_body
          
          # DEBUG: Log what we're actually sending
          info "task=msteams payload_class=#{payload.class} payload_size=#{body.bytesize} bytes"
          
          response = http(base_url(url)).post(url) do |request|
            request.options.timeout = timeout
            request.headers['Content-Type'] = 'application/json'
            request.body = body
          end

          unless response.success?
            error "task=msteams url=#{mask_url(url)} status=#{response.status} body=#{response.body}"
            # DEBUG: Log first 500 chars of what we sent
            error "task=msteams sent_body=#{body[0..500]}"
          end
        rescue URI::InvalidURIError => e
          error "task=msteams status=invalid_uri url=#{mask_url(url)}"
        rescue => e
          error "task=msteams status=error url=#{mask_url(url)} error=#{e.message}"
        end

        def payload_body
          # payload might already be JSON string from Sidekiq serialization
          payload.is_a?(String) ? payload : MultiJson.encode(payload)
        end

        def mask_url(url)
          # Mask sensitive parts of MS Teams webhook URL
          url.to_s.gsub(%r{/webhook/[^/]+/}, '/webhook/***/').gsub(%r{/[a-zA-Z0-9_-]{12,}(/|\z)}, '/***\1')
        end

        def targets
          params[:targets]
        end

        def payload
          params[:payload]
        end

        def base_url(url)
          URI.parse(url).tap { |uri| uri.path = '/' }.to_s
        end
      end
    end
  end
end
