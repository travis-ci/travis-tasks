require 'openssl'
require 'base64'

module Travis
  module Addons
    module Webhook
      class InvalidTokenError < StandardError; end
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
              add_headers(req, target, req.body[:payload])
            end

            if response.success?
              log_success(response)
            else
              log_error(response)
            end
          rescue URI::InvalidURIError => e
            error "task=webhook status=invalid_uri build=#{payload[:id]} slug=#{repo_slug} url=#{target}"
          end

          def add_headers(request, target, payload)
            uri = URI(target)
            if uri.user && uri.password
              request.headers['Authorization'] = basicauth(uri.user, uri.password)
            end
            if add_signature?
              request.headers['Signature'] = signature(payload)
            end
            request.headers['Travis-Repo-Slug'] = repo_slug
            request.headers['User-Agent'] = "Travis CI Notifications"
          end

          def basicauth(user, password)
            Faraday::Request::BasicAuthentication.header(
              URI.unescape(user), URI.unescape(password)
            )
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
