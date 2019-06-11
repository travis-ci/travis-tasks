require 'travis/addons/email/task'
require 'travis/addons/billing/mailer/helpers'
require 'travis/addons/billing/mailer/billing_mailer'

module Travis
  module Addons
    module Billing

      # Sends out billing emails using ActionMailer.
      class Task < Travis::Addons::Email::Task
        # checks whether to send invoice_payment_succeeded emails or charge_failed email
        def type
          :"#{params[:email_type]}"
        end

        def subscription
          params[:subscription]
        end

        def owner
          params[:owner]
        end

        # charge and event is only needed for charge_failed email
        def charge
          params[:charge]
        end

        def event
          params[:event]
        end

        # invoice and cc_last_digits is only needed for invoice_payment_succeeded email
        def invoice
          params[:invoice]
        end

        def cc_last_digits
          params[:cc_last_digits]
        end

        private

          def send_email
            Mailer::BillingMailer.public_send(params[:email_type], recipients, subscription, owner, charge, event, invoice, cc_last_digits).deliver
            emails = recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')
            info "type=#{type} status=sent msg='email sent #{emails}'"
          end
      end
    end
  end
end
