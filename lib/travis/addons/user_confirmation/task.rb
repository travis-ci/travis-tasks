# frozen_string_literal: true

require 'travis/addons/email/task'
require 'travis/addons/user_confirmation/mailer/user_confirmation_mailer'

module Travis
  module Addons
    module UserConfirmation
      # Sends out trial emails using ActionMailer.
      class Task < Travis::Addons::Email::Task
        def type
          :"#{params[:stage]}"
        end

        private

        def send_email
          Mailer::UserConfirmationMailer.public_send(params[:stage], recipients, **mailer_params).deliver
          Travis.logger.info "type=#{type} status=sent msg='email sent' #{recipients.map do |r|
                                                              "email=#{obfuscate_email_address(r)}"
                                                            end.join(' ')}"
        end

        def mailer_params
          params.select { |k, _v| %i[owner confirmation_url token_valid_to].include?(k) }
        end
      end
    end
  end
end
