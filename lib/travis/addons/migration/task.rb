require 'travis/addons/email/task'
require 'travis/addons/migration/mailer/migration_mailer'

module Travis
  module Addons
    module Migration
      class Task < Travis::Addons::Email::Task

        protected

        def send_email
          Mailer::MigrationMailer.beta_confirmation(recipients, params.fetch(:user_name), params.fetch(:organizations)).deliver

          emails = recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')
          info "type=#{params.fetch(:email_type)} status=sent msg='email sent #{emails}"
        end
      end
    end
  end
end
