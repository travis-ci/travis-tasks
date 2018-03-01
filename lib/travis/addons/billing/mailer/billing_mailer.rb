require 'action_mailer'

module Travis
  module Addons
    module Billing
      module Mailer
        class BillingMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          layout 'yield_email'

          def charge_failed(billing_email, subscription, owner, charge, event)
            @billing_email, @subscription, @owner, @charge, @event = billing_email, subscription, owner, charge, event
            subject = "Travis CI: Charging Your Credit Card Failed"
            mail(from: from, to: to, reply_to: reply_to, bcc: @billing_email, subject: subject, template_path: 'billing_mailer')
          end

          private

            def from
              "Travis CI <#{from_email}>"
            end

            def from_email
              config.email && config.email.from || "support@#{config.host}"
            end

            def to
              # config.email && config.email.trials_to_placeholder
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
        end
      end
    end
  end
end
