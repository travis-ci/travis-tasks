require 'travis/addons/email/task'
require 'lib/travis/addons/user_confirmation/mailer/user_confirmation_mailer'

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

        def confirmation_url
          params[:confirmation_url]
        end

        private

        def send_email
          Mailer::UserConfirmationMailer.public_send(params[:stage], recipients, owner, confirmation_url).deliver
          info "type=#{type} status=sent msg='email sent' #{recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')}"
        end
      end
    end
  end
end