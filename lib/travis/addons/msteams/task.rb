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
          response = http(base_url(url)).post(url) do |request|
            request.options.timeout = timeout
            request.headers['Content-Type'] = 'application/json'
            request.body = MultiJson.encode(payload)
          end

          unless response.success?
            error "task=msteams build=#{build_id} repo=#{repo_slug} url=#{mask_url(url)} status=#{response.status} body=#{response.body}"
          end
        rescue URI::InvalidURIError => e
          error "task=msteams status=invalid_uri build=#{build_id} repo=#{repo_slug} url=#{mask_url(url)}"
        rescue => e
          error "task=msteams status=error build=#{build_id} repo=#{repo_slug} url=#{mask_url(url)} error=#{e.message}"
        end

        def mask_url(url)
          # Mask sensitive parts of MS Teams webhook URL
          # Pattern: https://outlook.office.com/webhook/abc123/IncomingWebhook/xyz/token
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

        def build_id
          build&.[](:id) || 'unknown'
        end

        def repo_slug
          repository&.[](:slug) || 'unknown'
        end
      end
    end
  end
end
