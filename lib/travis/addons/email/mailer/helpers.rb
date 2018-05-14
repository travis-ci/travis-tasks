require 'base64'
require 'rack'
require 'time'

module Travis
  module Addons
    module Email
      module Mailer
        module Helpers
          ONE_HOUR = 3600
          ONE_MINUTE = 60

          def asset_url(build_state)
            if(build_state.eql? 'canceled')
              "#{Travis.config.s3.url}/status-errored.png" 
            else
            "#{Travis.config.s3.url}/status-#{build_state}.png"
            end
          end

          def branch_url(repo, branch)
            "#{Travis.config.github.url}/#{repo.slug}/tree/#{branch}"
          end

          def broadcast_category(category)
            email_asset_base_url = 'https://s3.amazonaws.com/travis-email-assets'
            category == 'announcement' ? "#{email_asset_base_url}/announcement_dot.png" : "#{email_asset_base_url}/warning_dot.png"
          end

          def build_email_css_class(build)
            case build.state
            when 'failed', 'broken', 'failing'
              'failure'
            when 'fixed', 'passed'
              'success'
            else
              'error'
            end
          end

          def build_image_extension(build)
            case build.state
            when 'failed', 'broken', 'failing'
              'failed'
            when 'fixed', 'passed'
              'success'
            else
              'error'
            end
          end

          def build_status(status_result)
            status_result.gsub('.', '')
          end

          # 1 hour, 10 minutes, and 15 seconds
          # 1 hour, 0 minutes, and 5 seconds
          # 1 minutes and 1 second
          # 15 seconds
          def duration_in_words(started_at, finished_at)
            return '?' if started_at.nil? || finished_at.nil?

            started_at  = Time.parse(started_at)  if started_at.is_a?(String)
            finished_at = Time.parse(finished_at) if finished_at.is_a?(String)

            # difference in seconds
            diff = (finished_at - started_at).to_i

            hours   = diff / ONE_HOUR
            minutes = (diff % ONE_HOUR) / ONE_MINUTE
            seconds = diff % ONE_MINUTE

            time_pieces = []

            time_pieces << I18n.t(:'datetime.distance_in_words.hours_exact',   count: hours)   if hours > 0
            time_pieces << I18n.t(:'datetime.distance_in_words.minutes_exact', count: minutes) if hours > 0 || minutes > 0
            time_pieces << I18n.t(:'datetime.distance_in_words.seconds_exact', count: seconds)

            time_pieces.to_sentence
          end

          def gravatar_url(author_email)
            "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(author_email)}"
          end

          def organization_name(repository_slug)
            repository_slug.split('/').first
          end

          def repository_name(repository_slug)
            repository_slug.split('/').last
          end

          def repository_url(repository)
            url = "https://#{Travis.config.host}/#{repository.slug}"
            Travis.config.utm ? with_utm(url) :url
          end

          def repository_build_url(options)
            config = Travis.config
            url = [config.http_host, options[:slug], 'builds', options[:id]].join('/')
            config.utm ? with_utm(url) :url
          end

          def title(repository)
            "Build Update for #{repository.slug}"
          end

          def with_query_params(url, params)
            "#{url}?#{params.map { |pair| pair.join('=') }.join('&')}"
          end

          def with_utm(url)
            with_query_params(url, utm_source: :email, utm_medium: :notification)
          end
        end
      end
    end
  end
end
