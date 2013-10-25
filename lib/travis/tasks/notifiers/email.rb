require "action_mailer"
require "i18n"
require "mail"
require "travis/tasks/notifiers/email/mailer/build"
require "travis/tasks/notifiers/email/mailer/helpers"

module Travis
  module Tasks
    module Notifiers
      # Sends out build notification emails using ActionMailer.
      class Email < Notifier
        class << self
          def setup
            ActionMailer::Base.delivery_method = :smtp
            ActionMailer::Base.smtp_settings = Tasks.config.smtp
            ActionMailer::Base.append_view_path("#{base_dir}/views")
            I18n.load_path += Dir["#{base_dir}/locales/**/*.yml"]
          end

          def base_dir
            File.expand_path('../email/mailer', __FILE__)
          end
        end

        def recipients
          @recipients ||= params[:recipients].select { |email| valid?(email) }
        end

        def broadcasts
          broadcasts = params[:broadcasts]
        end

        def type
          :finished_email
        end

        private

          def process
            Mailer::Build.send(type, payload, recipients, broadcasts).deliver if recipients.any?
          rescue Net::SMTPServerBusy => e
            error("Could not send email to: #{recipients} (error: #{e.message})")
            raise unless e.message =~ /Bad recipient address syntax/ || e.message =~ /Recipient address rejected/
          rescue StandardError => e
            error("Could not send email to: #{recipients}")
            log_exception(e)
            raise
          end

          def valid?(email)
            # stolen from http://is.gd/Dzd6fp because of it's beauty and all
            return false if email =~ /\.local$/
            mail = Mail::Address.new(email)
            tree = mail.__send__(:tree)
            mail.domain && mail.address == email && (tree.domain.dot_atom_text.elements.size > 1)
          rescue Exception => e
            false
          end
      end
    end
  end
end
