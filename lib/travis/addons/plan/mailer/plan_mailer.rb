require 'action_mailer'

module Travis
  module Addons
    module Plan
      module Mailer
        class PlanMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          layout 'contact_email'

          def welcome(receivers, owner, plan)
            @owner = owner
            @vcs_name = humanize_vcs_type(owner)
            @signup_url = signup_url(owner)
            @plan = plan
            subject = "Welcome to Travis CI!"
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'plan_mailer')
          end

          private

            def from
              "Travis CI <#{from_email}>"
            end

            def from_email
              config.email && config.email.trials_from || "trials@#{config.host}"
            end

            def to
              config.email && config.email.trials_to_placeholder || "trials@#{config.host}"
            end

            def reply_to
              "Travis CI Support <#{reply_to_email}>"
            end

            def reply_to_email
              config.email && config.email.reply_to || "support@#{config.host}"
            end

            def config
              Travis.config
            end

            def humanize_vcs_type(owner)
              owner[:vcs_type].gsub('User', '').gsub('Organization', '')
            end

            def signup_url(owner)
              return "https://#{config.host}/account/plan" if owner[:billing_slug] == 'user'
              "https://#{config.host}/organizations/#{owner[:login]}/plan"
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
