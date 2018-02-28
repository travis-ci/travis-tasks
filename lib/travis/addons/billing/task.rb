require 'travis/addons/email/task'
require 'travis/addons/billing/mailer/billing_mailer'

module Travis
  module Addons
    module Billing

      # Sends out billing emails using ActionMailer.
      class Task < Travis::Addons::Email::Task
        def subscription
          params[:subscription]
        end

        # are charge and event is optional
        def charge
          params[:charge]
        end

        def event
          params[:event]
        end

        def recipient
          params[:billing_email]
        end

        private

          def send_email
            Mailer::BillingMailer.public_send(recipient, subscription, charge, event).deliver
            info "type=#{type} status=sent msg='email sent email=' #{ obfuscate_email_address(recipient) }"
          end
      end
    end
  end
end
