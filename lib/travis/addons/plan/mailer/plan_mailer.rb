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
            @signup_url = signup_url(owner)
            @plan = plan
            subject = 'Welcome to Travis CI!'
            mail(from: from, to: receivers, reply_to: reply_to, subject: subject, template_path: 'plan_mailer')
          end

          def builds_not_allowed(receivers, owner, repository_url)
            @owner = owner
            @plan_url = plan_url(owner)
            @purchase_url = purchase_url(owner)
            @repository_url = repository_url
            subject = 'Builds have been temporarily disabled'
            mail(from: from, to: receivers, reply_to: reply_to, subject: subject, template_path: 'plan_mailer')
          end

          def credit_balance_state(receivers, owner, state)
            @owner = owner
            @plan_url = plan_url(owner)
            @state = state # integer number of percentage usage
            subject = 'Credits balance state notification'
            mail(from: from, to: receivers, reply_to: reply_to, subject: subject, template_path: 'plan_mailer')
          end

          def private_credits_for_public(receivers, owner, repository_url, renewal_date)
            @owner = owner
            @plan_url = plan_url(owner)
            @settings_url = settings_url(owner)
            @repository_url = repository_url
            @renewal_date = renewal_date
            subject = 'Builds have been temporarily disabled'
            mail(from: from, to: receivers, reply_to: reply_to, subject: subject, template_path: 'plan_mailer')
          end

          private

            def from
              "\"Travis CI\" <#{from_email % result_message.short.downcase}>"
            end

            def from_email
              Travis.config.email.from || "notifications@#{Travis.config.host}"
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

            def plan_url(owner)
              return "https://#{config.host}/account/#{config.plan_path}" if owner[:billing_slug] == 'user'
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.plan_path}"
            end

            def purchase_url(owner)
              return "https://#{config.host}/account/#{config.purchase_path}" if owner[:billing_slug] == 'user'
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.purchase_path}"
            end

            def settings_url(owner)
              return "https://#{config.host}/account/#{config.settnigs_path}" if owner[:billing_slug] == 'user'
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.settings_path}"
            end
        end
      end
    end
  end
end
