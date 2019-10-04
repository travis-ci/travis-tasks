require 'travis/addons/email/task'
require 'travis/addons/billing_feedback/mailer/billing_feedback_mailer'

module Travis
  module Addons
    module BillingFeedback

      # Sends out billing emails using ActionMailer.
      class Task < Travis::Addons::Email::Task
        def type
          :"#{params[:email_type]}"
        end

        def subscription
          params[:subscription]
        end

        def owner
          params[:owner]
        end

        def feedback
          params[:feedback]
        end

        def user
          params[:user]
        end

        private

          def send_email
            Mailer::BillingFeedbackMailer.public_send(params[:email_type], recipients, subscription, owner, user, feedback).deliver
            emails = recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')
            info "type=#{type} status=sent msg='email sent #{emails} and cancellations@travis-ci.com"
          end
      end
    end
  end
end
