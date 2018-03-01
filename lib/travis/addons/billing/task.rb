require 'travis/addons/email/task'
require 'travis/addons/billing/mailer/billing_mailer'

module Travis
  module Addons
    module Billing

      # Sends out billing emails using ActionMailer.
      class Task < Travis::Addons::Email::Task
        def type
          :"#{params[:email_type]}"
        end

        def subscription
          params[:subscription]
        end

        # charge and event is optional
        def charge
          params[:charge]
        end

        def event
          params[:event]
        end

        def owner
          params[:owner]
        end

        def billing_email
          params[:billing_email]
        end

        private

          def send_email
            Mailer::BillingMailer.public_send(params[:email_type], billing_email, subscription, owner, charge, event).deliver
            info "type=#{type} status=sent msg='email sent email=' #{ obfuscate_email_address(billing_email) }"
          end
      end
    end
  end
end
