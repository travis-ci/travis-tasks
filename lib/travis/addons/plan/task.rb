require 'travis/addons/email/task'
require 'travis/addons/plan/mailer/plan_mailer'

module Travis
  module Addons
    module Plan
      # Sends out plan email using ActionMailer.
      class Task < Travis::Addons::Email::Task
        def type
          :"#{params[:stage]}"
        end

        def owner
          params[:owner]
        end

        private

          def send_email
            Travis.logger.info("DEBUGXAXAX planmailer: #{params[:stage]}, recipients: #{recipients.inspect}, owner: #{owner}, params: #{params}")
            Mailer::PlanMailer.public_send(params[:stage], recipients, owner, params).deliver
            info "type=#{type} status=sent msg='email sent' #{recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')}"
          end
      end
    end
  end
end
