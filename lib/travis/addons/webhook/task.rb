require 'openssl'
require 'base64'

module Travis
  module Addons
    module Webhook
      class WebhookError < StandardError; end

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Task < Travis::Task
        def targets
          params[:targets]
        end

        private

          def process(timeout)
            errors = {}

            Array(targets).each do |target|
              begin
                send_webhook(target, timeout)
              rescue => e
                error "task=webhook status=failed url=#{target}"
                errors[target] = e.message
              end
            end

            if errors.any?
              error "task=webhook failures=#{errors.size} build=#{payload[:id]} errors=#{errors}"
            end
          end

          def send_webhook(target, timeout)
            response = http.post(target) do |req|
              req.options.timeout = timeout
              req.body = { payload: payload.except(:params).to_json }
              uri = URI(target)
              if uri.user && uri.password
                req.headers['Authorization'] =
                  Faraday::Request::BasicAuthentication.header(
                    URI.unescape(uri.user), URI.unescape(uri.password)
                  )
              else
                req.headers['Authorization'] = authorization
              end
              if add_signature?
                req.headers['Signature'] = signature(req.body[:payload])
              end
              req.headers['Travis-Repo-Slug'] = repo_slug
              req.headers['User-Agent'] = "Travis CI Notifications"
            end

            response.success? ? log_success(response) : log_error(response)
          rescue URI::InvalidURIError => e
            error "task=webhook status=invalid_uri build=#{payload[:id]} slug=#{repo_slug} url=#{target}"
          end

          def authorization
            Digest::SHA2.hexdigest(repo_slug + params[:token].to_s)
          end

          def add_signature?
            Travis.config.webhook.signing_private_key?
          end

          def signature(content)
            key = OpenSSL::PKey::RSA.new(Travis.config.webhook.signing_private_key)
            Base64.encode64(key.sign(OpenSSL::Digest::SHA1.new, content)).gsub("\n","")
          end

          def log_success(response)
            info "task=webhook status=successful build=#{payload[:id]} url=#{response.env[:url].to_s}"
          end

          def log_error(response)
            error "task=webhook status=error build=#{payload[:id]} url=#{response.env[:url].to_s} error_code=#{response.status} message=#{response.body.inspect}"
          end

          def repo_slug
            repository.values_at(:owner_name, :name).join('/')
          end
      end
    end
  end
end
