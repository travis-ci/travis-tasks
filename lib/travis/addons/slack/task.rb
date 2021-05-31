
module Travis
  module Addons
    module Slack
      class Task < Travis::Task

        BRANCH_BUILD_MESSAGE_TEMPLATE = "Build <%{build_url}|#%{build_number}> (<%{compare_url}|%{commit}>) of %{repository}@%{branch} by %{author} %{result} in %{elapsed_time}"
        PULL_REQUEST_MESSAGE_TEMPLATE = "Build <%{build_url}|#%{build_number}> (<%{compare_url}|%{commit}>) of %{repository}@%{branch} in PR <%{pull_request_url}|#%{pull_request_number}> by %{author} %{result} in %{elapsed_time}"

        def process(timeout)
          targets.each do |target|
            if illegal_format?(target)
              warn "task=slack build=#{build[:id]} repo=#{repository[:slug]} result=invalid_target target=#{target}"
            else
              send_message(target, timeout)
            end
          end
        end

        def illegal_format?(target)
          !target.match(/^[a-zA-Z0-9-]+:[a-zA-Z0-9_-]+(#.+)?$/)
        end

        def send_message(target, timeout)
          url, channel = parse(target)
          response = http(base_url(url)).post(url) do |request|
            request.options.timeout = timeout
            request.body = MultiJson.encode(message(channel))
          end

          unless response.success?
            warn "task=slack build=#{build[:id]} repo=#{repository[:slug]} response_status=#{response.status} response_body=#{response.body}"
          end
        end

        def parse(target)
          account, appendix = target.split(":")
          token, channel = appendix.split("#")
          if channel.present?
            channel = "##{channel}"
          end
          url = "https://#{account}.slack.com/services/hooks/travis?token=#{token}"
          [url, channel]
        end

        def message(channel)
          text = message_text
          message = {
            attachments: [{
              fallback: text,
              text: text,
              color: color,
              mrkdwn_in: ["text"]
            }],
            icon_url: "https://travis-ci.org/images/travis-mascot-150.png"
          }

          if channel.present?
            message[:channel] = "#{channel}"
          end

          message
        end

        def message_text
          lines = Array(template || template_from_config || default_template)
          lines.map {|line| Util::Template.new(line, payload, source: :slack).interpolate}.join("\n")
        end

        def color
          case build[:state].to_s
          when "passed"
            "good"
          when "failed"
            "danger"
          else
            "warning"
          end
        end

        def targets
          params[:targets]
        end

        def template
          params[:template]
        end

        def template_from_config
          slack_config.is_a?(Hash) ? slack_config[:template] : nil
        end

        def slack_config
          build[:config].try(:[], :notifications).try(:[], :slack) || {}
        end

        def default_template
          if pull_request?
            PULL_REQUEST_MESSAGE_TEMPLATE
          else
            BRANCH_BUILD_MESSAGE_TEMPLATE
          end
        end
      end
    end
  end
end
