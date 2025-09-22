require 'travis/addons/email/task'
require 'travis/addons/gdpr/mailer/gdpr_mailer'

module Travis
  module Addons
    module Gdpr
      class Task < Travis::Addons::Email::Task
        class NoMailType < StandardError; end

        private

        def send_email
          type = params.fetch(:email_type)
          case type
          when 'export'
            Mailer::GdprMailer.export(recipients, params.fetch(:user_name), params.fetch(:url)).deliver
          when 'support_export'
            Mailer::GdprMailer.support_export(recipients, params.fetch(:user_name), params.fetch(:url)).deliver
          when 'purge'
            Mailer::GdprMailer.purge(recipients, params.fetch(:request_date)).deliver
          when 'data_retention_notice'
            Mailer::GdprMailer.data_retention_notice(recipients, params.fetch(:owner), params.fetch(:retention)).deliver
          when 'upcoming_data_deletion_notice'
            Mailer::GdprMailer.upcoming_data_deletion_notice(recipients, params.fetch(:owner), params.fetch(:retention)).deliver
          when 'data_deletion_confirmation'
            Mailer::GdprMailer.data_deletion_confirmation(recipients, params.fetch(:owner), params.fetch(:retention)).deliver
          else
            raise NoMailType, "#{type} is not a valid email type"
          end

          emails = recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')
          info "type=#{type} status=sent msg='email sent #{emails}"
        end
      end
    end
  end
end
