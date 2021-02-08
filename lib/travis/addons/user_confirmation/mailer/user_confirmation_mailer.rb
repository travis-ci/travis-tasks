require 'action_mailer'

module Travis
  module Addons
    module Trial
      module Mailer
        class UserConfirmationMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          layout 'contact_email'

          def account_activated(receivers, **options)
            @owner = options.values_at(:owner)
            subject = 'Travis CI: Your account has been activated!'
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'user_confirmation_mailer')
          end

          def confirm_account(receivers, **options)
            @owner, @confirmation_url, @token_valid_to = options.values_at(:owner, :confirmation_url, :token_valid_to)
            subject = 'Travis CI: Confirm your account.'
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'user_confirmation_mailer')
          end

          private

          def filter_receivers(receivers)
            receivers = receivers.flatten.uniq.compact
            receivers.reject { |email| email.include?("[") || email.include?(" ") || email.ends_with?(".home") }
          end

          def from
            "Travis CI <#{from_email}>"
          end

          def from_email
            config.email&.user_confirmation_from || "user_confirmation@#{config.host}"
          end

          def to
            config.email&.user_confirmation_to_placeholder || "user_confirmation@#{config.host}"
          end

          def reply_to
            "Travis CI Support <#{reply_to_email}>"
          end

          def reply_to_email
            config.email&.reply_to || "support@#{config.host}"
          end

          def config
            Travis.config
          end
        end
      end
    end
  end
end
