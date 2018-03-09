require 'action_mailer'

module Travis
  module Addons
    module Billing
      module Mailer
        class BillingMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          def charge_failed(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription, @owner, @charge, @event = subscription, owner, charge, event
            @next_payment_attempt = Time.at(@event[:next_payment_attempt]).strftime('%F')
            subject = "Travis CI: Charging Your Credit Card Failed"
            mail(from: travis_email, to: receivers, subject: subject, template_path: 'billing_mailer')
          end

          def invoice_payment_succeeded(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription, @owner, @invoice, @cc_last_digits = subscription, owner, invoice, cc_last_digits
            subject = "Travis CI: Your Invoice"
            mail(from: travis_email, to: receivers, subject: subject, template_path: 'billing_mailer')
          end

          def subscription_cancelled(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription = subscription
            subject = "Travis CI: Cancellation confirmed"
            mail(from: travis_email, to: receivers, subject: subject, template_path: 'billing_mailer')
          end

          def user_feedback(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription, @owner = subscription, owner
            subject = "Subscription cancelled for #{owner[:login]}"
            mail(from: travis_email, to: travis_email, reply_to: receivers, subject: subject, template_path: 'billing_mailer')
          end
          private

            def travis_email
              "Travis CI <#{from_email}>"
            end

            def from_email
              "success@travis-ci.com"
            end
        end
      end
    end
  end
end
