require 'action_mailer'

module Travis
  module Addons
    module Billing
      module Mailer
        class BillingMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          layout 'yield_email'

          def charge_failed(subscription, owner, charge, event)
            @subscription, @owner, @charge, @event = subscription, owner, charge, event
            @billing_email = @subscription[:billing_email]
            subject = "Travis CI: Charging Your Credit Card Failed"
            mail(from: from, to: @billing_email, subject: subject, template_path: 'billing_mailer')
          end

          private

            def from
              "Travis CI <#{from_email}>"
            end

            def from_email
              config.email && config.email.from || "support@#{config.host}"
            end

            def config
              Travis.config
            end
        end
      end
    end
  end
end
