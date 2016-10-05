module Travis
  module Addons
    module Discord
      class Task < Travis::Task

        DEFAULT_BRANCH_TEMPLATE = "Build [#%{build_number}](%{build_url}) ([%{commit}](%{compare_url})) of %{repository}@%{branch} by %{author} %{result} in %{duration}"
        DEFAULT_PULL_REQUEST_TEMPLATE = "Build [#%{build_number}](%{build_url}) ([%{commit}](%{compare_url})) of %{repository}@%{branch} in PR [#%{pull_request_number}](%{pull_request_url}) by %{author} %{result} in %{duration}"

        def process(timeout)
          targets.each do |target|
            if illegal_format?(target)
              warn "task=discord build=#{payload[:id]} result=invalid_target target=#{target}"
            else
              send_message(target, timeout)
            end
          end
        end

        def targets
          params[:targets]
        end

        def illegal_format?(target)
          !target.match(/^[0-9]+:[a-zA-Z0-9_-]+$/)
        end

        def send_message(target, timeout)
          id, token = target.split(":")
          http.post("https://discordapp.com/api/webhooks/#{id}/#{token}") do |request|
            request.options.timeout = timeout
            request.body = MultiJson.encode(message)
          end
        end

        def message
          {
            embeds: [{
              description: description,
              color: color
            }],
            avatar_url: "https://travis-ci.org/images/travis-mascot-150.png"
          }
        end

        def description
          lines = Array(template_from_config || default_template)
          lines.map {|line| Util::Template.new(line, payload).interpolate}.join("\n")
        end

        def color
          case build[:state].to_s
          when "passed"
            38912
          when "failed"
            16525609
          else
            7506394
          end
        end

        def template_from_config
          if discord_config.is_a?(Hash)
            if pull_request?
              discord_config[:pull_request_template]
            else
              discord_config[:branch_template]
            end
          else
            nil
          end
        end

        def discord_config
          build[:config].try(:[], :notifications).try(:[], :discord) || {}
        end

        def default_template
          if pull_request?
            DEFAULT_PULL_REQUEST_TEMPLATE
          else
            DEFAULT_BRANCH_TEMPLATE
          end
        end
      end
    end
  end
end
