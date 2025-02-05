require 'action_mailer'

module Travis
  module Addons
    module Trial
      module Mailer
        class TrialMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          layout 'contact_email'

          def trial_started(receivers, owner, builds_remaining)
            @owner, @builds_remaining = owner, builds_remaining
            @vcs_name = humanize_vcs_type(owner)
            @signin_url = signin_url(owner)
            subject = "Welcome to Travis CI!"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          def trial_halfway(receivers, owner, builds_remaining)
            @owner, @builds_remaining = owner, builds_remaining
            @vcs_name = humanize_vcs_type(owner)
            @signin_url = signin_url(owner)
            subject = "Travis CI: Halfway through your trial"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          def trial_about_to_end(receivers, owner, builds_remaining)
            @owner, @builds_remaining = owner, builds_remaining
            @vcs_name = humanize_vcs_type(owner)
            @signin_url = signin_url(owner)
            subject = "Travis CI: #{builds_remaining} builds left in your trial"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          def trial_ended(receivers, owner, builds_remaining)
            @owner = owner
            @vcs_name = humanize_vcs_type(owner)
            @signin_url = signin_url(owner)
            subject = "Your Travis CI trial just ended!"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          private

            def from
              "Travis CI <#{from_email}>"
            end

            def from_email
              config.emails && config.emails.trials_from || "no-reply@#{config.host_domain}"
            end

            def to
              config.emails && config.emails.trials_to_placeholder || "no-reply@#{config.host_domain}"
            end

            def config
              Travis.config
            end

            def humanize_vcs_type(owner)
              owner[:vcs_type].gsub('User', '').gsub('Organization', '')
            end

            def signin_url(owner)
              return 'https://travis-ci.com/account/subscription' if owner[:billing_slug] == 'user'
              "https://travis-ci.com/organizations/#{owner[:login]}/subscription"
            end

            def filter_receivers(receivers)
              receivers = receivers.flatten.uniq.compact
              receivers.reject { |email| email.include?("[") || email.include?(" ") || email.ends_with?(".home") }
            end
        end
      end
    end
  end
end
