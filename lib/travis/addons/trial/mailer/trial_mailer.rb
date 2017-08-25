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
            subject = "Welcome to your Travis CI trial!"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          def trial_halfway(receivers, owner, builds_remaining)
            @owner, @builds_remaining = owner, builds_remaining
            subject = "Travis CI: Halfway through your trial"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          def trial_about_to_end(receivers, owner, builds_remaining)
            @owner, @builds_remaining = owner, builds_remaining
            subject = "Travis CI: #{builds_remaining} builds left in your trial"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          def trial_ended(receivers, owner, builds_remaining)
            @owner = owner
            subject = "Your Travis CI trial just ended!"
            mail(from: from, to: to, bcc: filter_receivers(receivers), subject: subject, template_path: 'trial_mailer')
          end

          private

            def from
              config.email && config.email.from || "builds@#{config.host}"
            end

            def to
              config.email && config.email.trials_to_placeholder || "trials@#{config.host}"
            end

            def config
              Travis.config
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
