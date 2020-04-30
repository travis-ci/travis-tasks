require 'openssl'
require 'base64'
require 'travis/addons/webhook/payload'

module Travis
  module Addons
    module Webhook
      class WebhookError < StandardError; end

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Task < Travis::Task
        def initialize(payload, params = {})
          payload = payload.except(:params) # TODO do we really include these in the payload?
          payload = Payload.new(payload.deep_symbolize_keys).data unless payload.key?('status_message')
          super
        end

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
                error "task=webhook status=failed url=#{loggable_url(target)}"
                errors[target] = e.message
              end
            end

            if errors.any?
              error "task=webhook failures=#{errors.size} build=#{payload[:id]} errors=#{errors}"
            end
          end

          def send_webhook(target, timeout)
            response = http(base_url(target)).post(target) do |req|
              req.options.timeout = timeout
              req.body = { payload: payload.to_json }
              add_headers(req, target, req.body[:payload])
            end

            if response.success?
              log_success(response)
            else
              log_error(response)
            end
          rescue URI::InvalidURIError => e
            error "task=webhook status=invalid_uri build=#{payload[:id]} slug=#{repo_slug} url=#{loggable_url(target)}"
          end

          def add_headers(request, target, payload)
            uri = URI(target)
            if uri.user && uri.password
              request.headers['Authorization'] = basic_auth(uri.user, uri.password)
            end
            if add_signature?
              request.headers['Signature'] = signature(payload)
            end
            request.headers['Travis-Repo-Slug'] = repo_slug
            request.headers['User-Agent'] = "Travis CI Notifications"
          end

          def basic_auth(user, password)
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
            info "task=webhook status=successful build=#{payload[:id]} url=#{loggable_url(response.env[:url].to_s)}"
          end

          def log_error(response)
            error "task=webhook status=error build=#{payload[:id]} url=#{loggable_url(response.env[:url].to_s)} error_code=#{response.status} message=#{response.body.inspect}"
          end

          def repo_slug
            repository.values_at(:owner_name, :name).join('/')
          end

          def loggable_url(url)
            u = URI.parse(url)
            u.user = u.password = nil
            u.to_s
          end
      end
    end
  end
end
