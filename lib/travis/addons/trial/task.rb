require 'travis/addons/email/task'
require 'travis/addons/trial/mailer/trial_mailer'

module Travis
  module Addons
    module Trial

      # Sends out trial emails using ActionMailer.
      class Task < Travis::Addons::Email::Task
        def type
          :"#{params[:stage]}"
        end

        def owner
          params[:owner]
        end

        def builds_remaining
          params.fetch(:builds_remaining, '0').to_i
        end

        private

          def send_email
            Mailer::TrialMailer.public_send(params[:stage], recipients, owner, builds_remaining).deliver
            info "type=#{type} status=sent msg='email sent' #{recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')}"
          end
      end
    end
  end
end
