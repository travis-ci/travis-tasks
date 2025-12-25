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

        def msteams_flags
          params[:msteams] || {}
        end

        def msteams_payload
          params[:msteams_payload]
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
            use_msteams = msteams_flags[target]

            if use_msteams
              # For MS Teams, use a plain HTTP connection without url_encoded middleware
              response = plain_http(base_url(target)).post(target) do |req|
                req.options.timeout = timeout
                req.headers['Content-Type'] = 'application/json'
                req.body = msteams_payload.to_json
                add_headers(req, target, use_msteams)
              end
            else
              # Traditional webhook format with url_encoded middleware
              response = http(base_url(target)).post(target) do |req|
                req.options.timeout = timeout
                req.body = { payload: payload.to_json }
                add_headers(req, target, use_msteams)
              end
            end

            if response.success?
              log_success(response, use_msteams)
            else
              log_error(response, use_msteams)
            end
          rescue URI::InvalidURIError => e
            error "task=webhook status=invalid_uri build=#{payload[:id]} slug=#{repo_slug} url=#{loggable_url(target)}"
          end

          def add_headers(request, target, use_msteams)
            uri = URI(target)
            if uri.user && uri.password
              request.headers['Authorization'] = basic_auth(uri.user, uri.password)
            end

            # Only add signature for traditional webhooks
            unless use_msteams
              if add_signature?
                request.headers['Signature'] = signature(request.body[:payload])
              end
            end

            request.headers['Travis-Repo-Slug'] = repo_slug
            request.headers['User-Agent'] = "Travis CI Notifications"
          end

          def plain_http(url)
            # HTTP connection without url_encoded middleware for JSON payloads
            @plain_http ||= Faraday.new(http_options.merge(url: url)) do |f|
              f.response :follow_redirects
              f.headers["User-Agent"] = user_agent_string
              f.adapter :net_http
            end
          end

          def basic_auth(user, password)
            Faraday::Request::Authorization.new(:basic,
              CGI.unescape(user), CGI.unescape(password)
            )
          end

          def add_signature?
            Travis.config.webhook.signing_private_key?
          end

          def signature(content)
            key = OpenSSL::PKey::RSA.new(Travis.config.webhook.signing_private_key)
            Base64.encode64(key.sign(OpenSSL::Digest::SHA1.new, content)).gsub("\n","")
          end

          def log_success(response, use_msteams = false)
            format_type = use_msteams ? 'msteams' : 'webhook'
            info "task=webhook format=#{format_type} status=successful build=#{payload[:id]} url=#{loggable_url(response.env[:url].to_s)}"
          end

          def log_error(response, use_msteams = false)
            format_type = use_msteams ? 'msteams' : 'webhook'
            error "task=webhook format=#{format_type} status=error build=#{payload[:id]} url=#{loggable_url(response.env[:url].to_s)} error_code=#{response.status} message=#{response.body.inspect}"
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
